#!/usr/bin/env python3
"""
Archive.org Web Scraper para Documentos da Polícia Federal
Autor: Script Automatizado
Descrição: Busca e baixa provas antigas, editais e PDFs relacionados a concursos
           da Polícia Federal nos domínios Cebraspe/CESPE através do Archive.org
"""

import os
import sys
import time
import json
import logging
import hashlib
import requests
from datetime import datetime
from urllib.parse import urljoin, urlparse, quote
from typing import List, Dict, Set, Optional, Tuple
import re
from concurrent.futures import ThreadPoolExecutor, as_completed
from bs4 import BeautifulSoup
import pandas as pd
from tqdm import tqdm
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

# Configuração de logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('archive_scraper.log', encoding='utf-8'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)


class ArchiveScraper:
    """Classe principal para fazer scraping no Archive.org"""
    
    def __init__(self, output_dir: str = "documentos_pf", max_workers: int = 5):
        """
        Inicializa o scraper
        
        Args:
            output_dir: Diretório onde os arquivos serão salvos
            max_workers: Número máximo de threads para download paralelo
        """
        self.output_dir = output_dir
        self.max_workers = max_workers
        self.session = self._create_session()
        self.found_documents = []
        self.downloaded_hashes = set()
        self.rate_limit_delay = 1.0  # Delay inicial entre requisições
        
        # Criar estrutura de diretórios
        self._create_directories()
        
        # Carregar hashes de documentos já baixados
        self._load_downloaded_hashes()
        
    def _create_session(self) -> requests.Session:
        """Cria uma sessão com retry automático"""
        session = requests.Session()
        retry_strategy = Retry(
            total=3,
            backoff_factor=1,
            status_forcelist=[429, 500, 502, 503, 504],
        )
        adapter = HTTPAdapter(max_retries=retry_strategy)
        session.mount("http://", adapter)
        session.mount("https://", adapter)
        session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        })
        return session
        
    def _create_directories(self):
        """Cria estrutura de diretórios para organizar os downloads"""
        subdirs = ['provas', 'editais', 'outros', 'relatorios']
        for subdir in subdirs:
            path = os.path.join(self.output_dir, subdir)
            os.makedirs(path, exist_ok=True)
            
    def _load_downloaded_hashes(self):
        """Carrega hashes de arquivos já baixados para evitar duplicatas"""
        hash_file = os.path.join(self.output_dir, 'downloaded_hashes.json')
        if os.path.exists(hash_file):
            try:
                with open(hash_file, 'r') as f:
                    self.downloaded_hashes = set(json.load(f))
                logger.info(f"Carregados {len(self.downloaded_hashes)} hashes de arquivos já baixados")
            except Exception as e:
                logger.error(f"Erro ao carregar hashes: {e}")
                
    def _save_downloaded_hashes(self):
        """Salva hashes de arquivos baixados"""
        hash_file = os.path.join(self.output_dir, 'downloaded_hashes.json')
        try:
            with open(hash_file, 'w') as f:
                json.dump(list(self.downloaded_hashes), f)
        except Exception as e:
            logger.error(f"Erro ao salvar hashes: {e}")
            
    def search_archive_api(self, query: str, rows: int = 100, page: int = 1) -> List[Dict]:
        """
        Busca usando a API do Archive.org
        
        Args:
            query: Query de busca
            rows: Número de resultados por página
            page: Número da página
            
        Returns:
            Lista de resultados
        """
        try:
            url = "https://archive.org/advancedsearch.php"
            params = {
                'q': query,
                'fl': 'identifier,title,creator,date,description,mediatype,publicdate',
                'rows': rows,
                'page': page,
                'output': 'json'
            }
            
            time.sleep(self.rate_limit_delay)
            response = self.session.get(url, params=params, timeout=30)
            response.raise_for_status()
            
            data = response.json()
            return data.get('response', {}).get('docs', [])
            
        except requests.exceptions.HTTPError as e:
            if e.response.status_code == 429:
                self.rate_limit_delay *= 2
                logger.warning(f"Rate limit atingido. Aumentando delay para {self.rate_limit_delay}s")
            logger.error(f"Erro na busca API: {e}")
            return []
        except Exception as e:
            logger.error(f"Erro inesperado na busca API: {e}")
            return []
            
    def search_wayback_machine(self, domain: str, keywords: List[str]) -> List[Dict]:
        """
        Busca snapshots no Wayback Machine
        
        Args:
            domain: Domínio a ser buscado
            keywords: Palavras-chave para filtrar resultados
            
        Returns:
            Lista de URLs encontradas
        """
        results = []
        try:
            # API CDX do Wayback Machine
            cdx_url = "http://web.archive.org/cdx/search/cdx"
            params = {
                'url': f"{domain}/*",
                'matchType': 'prefix',
                'output': 'json',
                'fl': 'original,timestamp,statuscode,mimetype',
                'filter': 'statuscode:200',
                'collapse': 'urlkey'
            }
            
            time.sleep(self.rate_limit_delay)
            response = self.session.get(cdx_url, params=params, timeout=30)
            response.raise_for_status()
            
            data = response.json()
            
            # Filtrar resultados relevantes
            for item in data[1:]:  # Pular header
                url, timestamp, status, mimetype = item
                
                # Verificar se é PDF ou página relevante
                if self._is_relevant_url(url, keywords, mimetype):
                    wayback_url = f"https://web.archive.org/web/{timestamp}/{url}"
                    results.append({
                        'original_url': url,
                        'wayback_url': wayback_url,
                        'timestamp': timestamp,
                        'mimetype': mimetype
                    })
                    
            logger.info(f"Encontrados {len(results)} snapshots relevantes para {domain}")
            return results
            
        except Exception as e:
            logger.error(f"Erro ao buscar no Wayback Machine: {e}")
            return []
            
    def _is_relevant_url(self, url: str, keywords: List[str], mimetype: str = '') -> bool:
        """Verifica se uma URL é relevante baseada em palavras-chave"""
        url_lower = url.lower()
        
        # Verificar se é PDF
        if mimetype and 'pdf' in mimetype.lower():
            return True
            
        if url_lower.endswith('.pdf'):
            return True
            
        # Verificar palavras-chave
        relevant_terms = ['prova', 'edital', 'gabarito', 'concurso', 'policia', 'federal', 
                         'agente', 'escrivao', 'papiloscopista', 'delegado']
        
        for term in relevant_terms + keywords:
            if term.lower() in url_lower:
                return True
                
        return False
        
    def scrape_domain_pages(self, domain: str, max_depth: int = 3) -> List[str]:
        """
        Faz scraping de páginas do domínio buscando links para PDFs
        
        Args:
            domain: Domínio base para scraping
            max_depth: Profundidade máxima de busca
            
        Returns:
            Lista de URLs de PDFs encontrados
        """
        pdf_urls = []
        visited = set()
        to_visit = [(f"https://{domain}", 0)]
        
        while to_visit:
            url, depth = to_visit.pop(0)
            
            if url in visited or depth > max_depth:
                continue
                
            visited.add(url)
            
            try:
                time.sleep(self.rate_limit_delay)
                response = self.session.get(url, timeout=30)
                response.raise_for_status()
                
                soup = BeautifulSoup(response.content, 'html.parser')
                
                # Buscar links para PDFs
                for link in soup.find_all('a', href=True):
                    href = link['href']
                    full_url = urljoin(url, href)
                    
                    if full_url.lower().endswith('.pdf'):
                        pdf_urls.append(full_url)
                    elif depth < max_depth and domain in full_url:
                        to_visit.append((full_url, depth + 1))
                        
            except Exception as e:
                logger.debug(f"Erro ao fazer scraping de {url}: {e}")
                
        logger.info(f"Encontrados {len(pdf_urls)} PDFs em {domain}")
        return pdf_urls
        
    def download_file(self, url: str, category: str = 'outros') -> Optional[str]:
        """
        Baixa um arquivo
        
        Args:
            url: URL do arquivo
            category: Categoria do arquivo (provas, editais, outros)
            
        Returns:
            Caminho do arquivo salvo ou None se falhar
        """
        try:
            time.sleep(self.rate_limit_delay)
            response = self.session.get(url, timeout=60, stream=True)
            response.raise_for_status()
            
            # Gerar nome do arquivo
            content = response.content
            file_hash = hashlib.md5(content).hexdigest()
            
            # Verificar se já foi baixado
            if file_hash in self.downloaded_hashes:
                logger.debug(f"Arquivo já baixado: {url}")
                return None
                
            # Extrair nome do arquivo
            filename = self._extract_filename(url, response.headers)
            if not filename:
                filename = f"{file_hash}.pdf"
                
            # Determinar categoria baseada no nome
            if 'prova' in filename.lower():
                category = 'provas'
            elif 'edital' in filename.lower():
                category = 'editais'
                
            filepath = os.path.join(self.output_dir, category, filename)
            
            # Salvar arquivo
            with open(filepath, 'wb') as f:
                f.write(content)
                
            self.downloaded_hashes.add(file_hash)
            
            # Registrar documento encontrado
            self.found_documents.append({
                'url': url,
                'filename': filename,
                'category': category,
                'size': len(content),
                'hash': file_hash,
                'download_time': datetime.now().isoformat()
            })
            
            logger.info(f"Baixado: {filename} ({len(content)/1024/1024:.2f} MB)")
            return filepath
            
        except Exception as e:
            logger.error(f"Erro ao baixar {url}: {e}")
            return None
            
    def _extract_filename(self, url: str, headers: dict) -> Optional[str]:
        """Extrai nome do arquivo da URL ou headers"""
        # Tentar do header Content-Disposition
        cd = headers.get('content-disposition')
        if cd:
            match = re.search(r'filename[^;=\n]*=(([\'"]).*?\2|[^;\n]*)', cd)
            if match:
                filename = match.group(1).strip('"\'')
                return self._sanitize_filename(filename)
                
        # Extrair da URL
        parsed = urlparse(url)
        filename = os.path.basename(parsed.path)
        if filename and filename.endswith('.pdf'):
            return self._sanitize_filename(filename)
            
        return None
        
    def _sanitize_filename(self, filename: str) -> str:
        """Sanitiza nome de arquivo removendo caracteres inválidos"""
        filename = re.sub(r'[<>:"/\\|?*]', '_', filename)
        filename = filename.strip('. ')
        return filename[:200]  # Limitar tamanho
        
    def generate_search_queries(self) -> List[str]:
        """Gera queries de busca otimizadas"""
        base_queries = [
            'site:cebraspe.org.br filetype:pdf "polícia federal"',
            'site:cespe.unb.br filetype:pdf "polícia federal"',
            'cebraspe "prova" "polícia federal" filetype:pdf',
            'cespe "edital" "agente" "polícia federal" filetype:pdf',
            '"concurso público" "polícia federal" cebraspe filetype:pdf',
            'gabarito "polícia federal" cebraspe filetype:pdf',
            'site:cebraspe.org.br "agente de polícia federal" prova',
            'site:cespe.unb.br "escrivão" "polícia federal" pdf',
            'cebraspe "papiloscopista" "polícia federal" filetype:pdf',
            'cespe "delegado" "polícia federal" prova pdf'
        ]
        
        # Adicionar variações com anos
        years = range(2010, 2025)
        queries = base_queries.copy()
        
        for year in years:
            queries.extend([
                f'cebraspe "polícia federal" {year} filetype:pdf',
                f'site:cebraspe.org.br "edital" "pf" {year}',
                f'cespe "prova" "agente" {year} pdf'
            ])
            
        return queries
        
    def search_hidden_pdfs(self) -> List[str]:
        """Busca PDFs 'ocultos' usando padrões de URL comuns"""
        pdf_urls = []
        domains = ['cebraspe.org.br', 'cespe.unb.br']
        
        # Padrões comuns de URLs
        patterns = [
            'concursos/pf_{year}/arquivos/',
            'concursos/policia_federal_{year}/',
            'provas/pf/{year}/',
            'editais/pf/{year}/',
            'gabaritos/pf/{year}/',
            'arquivos/concursos/pf/',
            'storage/concursos/policia_federal/',
            'files/provas/pf/'
        ]
        
        # Nomes comuns de arquivos
        filenames = [
            'prova_agente_pf_{year}.pdf',
            'edital_pf_{year}.pdf',
            'gabarito_preliminar_pf_{year}.pdf',
            'gabarito_definitivo_pf_{year}.pdf',
            'prova_escrivao_pf_{year}.pdf',
            'prova_papiloscopista_pf_{year}.pdf',
            'edital_abertura_pf_{year}.pdf',
            'edital_retificacao_pf_{year}.pdf'
        ]
        
        for domain in domains:
            for year in range(2010, 2025):
                for pattern in patterns:
                    base_url = f"https://{domain}/{pattern.format(year=year)}"
                    
                    for filename in filenames:
                        url = urljoin(base_url, filename.format(year=year))
                        
                        # Verificar se URL existe
                        try:
                            response = self.session.head(url, timeout=10, allow_redirects=True)
                            if response.status_code == 200:
                                pdf_urls.append(url)
                                logger.info(f"PDF encontrado: {url}")
                        except:
                            pass
                            
                        time.sleep(0.5)  # Evitar rate limiting
                        
        return pdf_urls
        
    def run_complete_search(self):
        """Executa busca completa em todas as fontes"""
        logger.info("Iniciando busca completa por documentos da Polícia Federal...")
        
        all_urls = set()
        
        # 1. Buscar usando API do Archive.org
        logger.info("Fase 1: Buscando na API do Archive.org...")
        queries = self.generate_search_queries()
        
        for query in tqdm(queries, desc="Queries API"):
            for page in range(1, 6):  # Buscar até 5 páginas
                results = self.search_archive_api(query, rows=50, page=page)
                
                for result in results:
                    identifier = result.get('identifier', '')
                    if identifier:
                        # Buscar arquivos do item
                        files_url = f"https://archive.org/metadata/{identifier}/files"
                        try:
                            response = self.session.get(files_url, timeout=30)
                            files_data = response.json()
                            
                            for file_info in files_data.get('result', []):
                                if file_info.get('name', '').lower().endswith('.pdf'):
                                    pdf_url = f"https://archive.org/download/{identifier}/{file_info['name']}"
                                    all_urls.add(pdf_url)
                        except:
                            pass
                            
        # 2. Buscar no Wayback Machine
        logger.info("Fase 2: Buscando no Wayback Machine...")
        domains = ['cebraspe.org.br', 'cespe.unb.br']
        keywords = ['policia', 'federal', 'prova', 'edital', 'agente']
        
        for domain in domains:
            snapshots = self.search_wayback_machine(domain, keywords)
            for snapshot in snapshots:
                all_urls.add(snapshot['wayback_url'])
                
        # 3. Buscar PDFs ocultos
        logger.info("Fase 3: Buscando PDFs ocultos...")
        hidden_pdfs = self.search_hidden_pdfs()
        all_urls.update(hidden_pdfs)
        
        # 4. Fazer scraping direto dos domínios
        logger.info("Fase 4: Fazendo scraping dos domínios...")
        for domain in domains:
            try:
                pdf_urls = self.scrape_domain_pages(domain, max_depth=2)
                all_urls.update(pdf_urls)
            except Exception as e:
                logger.error(f"Erro no scraping de {domain}: {e}")
                
        # 5. Baixar todos os PDFs encontrados
        logger.info(f"Fase 5: Baixando {len(all_urls)} arquivos únicos encontrados...")
        
        with ThreadPoolExecutor(max_workers=self.max_workers) as executor:
            futures = {executor.submit(self.download_file, url): url for url in all_urls}
            
            for future in tqdm(as_completed(futures), total=len(futures), desc="Downloads"):
                url = futures[future]
                try:
                    result = future.result()
                except Exception as e:
                    logger.error(f"Erro ao processar {url}: {e}")
                    
        # 6. Salvar hashes e gerar relatório
        self._save_downloaded_hashes()
        self.generate_report()
        
    def generate_report(self):
        """Gera relatório detalhado dos documentos encontrados"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        # Relatório em JSON
        json_report = os.path.join(self.output_dir, 'relatorios', f'relatorio_{timestamp}.json')
        with open(json_report, 'w', encoding='utf-8') as f:
            json.dump(self.found_documents, f, ensure_ascii=False, indent=2)
            
        # Relatório em CSV
        if self.found_documents:
            df = pd.DataFrame(self.found_documents)
            csv_report = os.path.join(self.output_dir, 'relatorios', f'relatorio_{timestamp}.csv')
            df.to_csv(csv_report, index=False, encoding='utf-8')
            
            # Relatório em HTML
            html_report = os.path.join(self.output_dir, 'relatorios', f'relatorio_{timestamp}.html')
            self._generate_html_report(df, html_report)
            
        # Estatísticas
        total_docs = len(self.found_documents)
        total_size = sum(doc['size'] for doc in self.found_documents) / 1024 / 1024  # MB
        
        categories = {}
        for doc in self.found_documents:
            cat = doc['category']
            categories[cat] = categories.get(cat, 0) + 1
            
        logger.info(f"\n{'='*50}")
        logger.info(f"RESUMO DA BUSCA")
        logger.info(f"{'='*50}")
        logger.info(f"Total de documentos baixados: {total_docs}")
        logger.info(f"Tamanho total: {total_size:.2f} MB")
        logger.info(f"Distribuição por categoria:")
        for cat, count in categories.items():
            logger.info(f"  - {cat}: {count} documentos")
        logger.info(f"{'='*50}")
        
    def _generate_html_report(self, df: pd.DataFrame, filepath: str):
        """Gera relatório HTML interativo"""
        html_template = """
        <!DOCTYPE html>
        <html>
        <head>
            <title>Relatório de Documentos PF - Archive.org</title>
            <meta charset="utf-8">
            <style>
                body {{ font-family: Arial, sans-serif; margin: 20px; }}
                h1 {{ color: #333; }}
                table {{ border-collapse: collapse; width: 100%; margin-top: 20px; }}
                th, td {{ border: 1px solid #ddd; padding: 8px; text-align: left; }}
                th {{ background-color: #f2f2f2; font-weight: bold; }}
                tr:nth-child(even) {{ background-color: #f9f9f9; }}
                .stats {{ background-color: #e7f3ff; padding: 15px; border-radius: 5px; margin: 20px 0; }}
                .category-provas {{ color: #2e7d32; }}
                .category-editais {{ color: #1976d2; }}
                .category-outros {{ color: #f57c00; }}
            </style>
        </head>
        <body>
            <h1>Relatório de Documentos da Polícia Federal</h1>
            <p>Gerado em: {timestamp}</p>
            
            <div class="stats">
                <h2>Estatísticas</h2>
                <p>Total de documentos: <strong>{total_docs}</strong></p>
                <p>Tamanho total: <strong>{total_size:.2f} MB</strong></p>
                <p>Categorias: 
                    <span class="category-provas">Provas ({provas})</span> | 
                    <span class="category-editais">Editais ({editais})</span> | 
                    <span class="category-outros">Outros ({outros})</span>
                </p>
            </div>
            
            <h2>Documentos Encontrados</h2>
            <table>
                <thead>
                    <tr>
                        <th>Arquivo</th>
                        <th>Categoria</th>
                        <th>Tamanho (MB)</th>
                        <th>Data Download</th>
                        <th>URL Original</th>
                    </tr>
                </thead>
                <tbody>
                    {table_rows}
                </tbody>
            </table>
        </body>
        </html>
        """
        
        # Gerar linhas da tabela
        table_rows = ""
        for _, row in df.iterrows():
            size_mb = row['size'] / 1024 / 1024
            download_time = datetime.fromisoformat(row['download_time']).strftime('%d/%m/%Y %H:%M')
            
            table_rows += f"""
            <tr>
                <td>{row['filename']}</td>
                <td class="category-{row['category']}">{row['category']}</td>
                <td>{size_mb:.2f}</td>
                <td>{download_time}</td>
                <td><a href="{row['url']}" target="_blank">Link</a></td>
            </tr>
            """
            
        # Calcular estatísticas
        stats = df['category'].value_counts()
        
        html = html_template.format(
            timestamp=datetime.now().strftime('%d/%m/%Y %H:%M:%S'),
            total_docs=len(df),
            total_size=df['size'].sum() / 1024 / 1024,
            provas=stats.get('provas', 0),
            editais=stats.get('editais', 0),
            outros=stats.get('outros', 0),
            table_rows=table_rows
        )
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(html)


def main():
    """Função principal"""
    print("""
    ╔══════════════════════════════════════════════════════════╗
    ║          Archive.org Scraper - Documentos PF             ║
    ║                                                          ║
    ║  Busca automática de provas, editais e PDFs da          ║
    ║  Polícia Federal nos domínios Cebraspe/CESPE            ║
    ╚══════════════════════════════════════════════════════════╝
    """)
    
    # Configurações
    output_dir = input("Digite o diretório de saída (padrão: documentos_pf): ").strip()
    if not output_dir:
        output_dir = "documentos_pf"
        
    max_workers = input("Número de downloads simultâneos (padrão: 5): ").strip()
    try:
        max_workers = int(max_workers)
    except:
        max_workers = 5
        
    # Criar e executar scraper
    scraper = ArchiveScraper(output_dir, max_workers)
    
    try:
        scraper.run_complete_search()
        print(f"\nBusca concluída! Verifique os resultados em: {output_dir}")
    except KeyboardInterrupt:
        logger.info("Busca interrompida pelo usuário")
    except Exception as e:
        logger.error(f"Erro durante a execução: {e}")
        raise


if __name__ == "__main__":
    main()