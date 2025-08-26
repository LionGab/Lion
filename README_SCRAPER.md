# Archive.org Web Scraper - Documentos Polícia Federal

Este é um script Python profissional e completo para fazer web scraping no Archive.org, buscando especificamente documentos relacionados aos concursos da Polícia Federal nos domínios Cebraspe/CESPE.

## 🎯 Funcionalidades

### Busca Abrangente
- **API do Archive.org**: Utiliza a API oficial para busca eficiente
- **Wayback Machine**: Acessa snapshots históricos de páginas
- **Scraping Direto**: Faz scraping dos domínios ativos
- **PDFs Ocultos**: Busca arquivos usando padrões de URL comuns

### Tipos de Documentos
- ✅ Provas antigas de concursos para Agente da PF
- ✅ Editais (abertura, retificações, etc.)
- ✅ Gabaritos (preliminares e definitivos)
- ✅ Documentos para Escrivão, Papiloscopista e Delegado
- ✅ PDFs "ocultos" ou arquivados

### Recursos Avançados
- 🔄 Rate limiting inteligente
- 🧵 Downloads paralelos (configurável)
- 📊 Relatórios detalhados (JSON, CSV, HTML)
- 🔍 Detecção de duplicatas por hash
- 📁 Organização automática por categoria
- 🛡️ Tratamento robusto de erros
- 📝 Logging detalhado

## 🚀 Instalação Rápida

### Método 1: Instalação Automática
```bash
python setup_scraper.py
```

### Método 2: Instalação Manual
```bash
pip install -r requirements.txt
```

## 📋 Dependências

```
requests>=2.31.0      # Requisições HTTP
beautifulsoup4>=4.12.2 # Parsing HTML
pandas>=2.0.3         # Manipulação de dados
tqdm>=4.66.1          # Barras de progresso
urllib3>=2.0.4        # Utilitários URL
lxml>=4.9.3           # Parser XML/HTML
```

## 🎮 Como Usar

### Uso Básico
```bash
python archive_pf_scraper.py
```

### Uso Programático
```python
from archive_pf_scraper import ArchiveScraper

# Criar instância do scraper
scraper = ArchiveScraper(
    output_dir="meus_documentos",
    max_workers=3
)

# Executar busca completa
scraper.run_complete_search()

# Ou usar métodos específicos
api_results = scraper.search_archive_api("cebraspe polícia federal filetype:pdf")
wayback_results = scraper.search_wayback_machine("cebraspe.org.br", ["prova", "edital"])
```

## 📂 Estrutura de Saída

```
documentos_pf/
├── provas/                 # Provas de concursos
├── editais/               # Editais e documentos oficiais
├── outros/                # Outros documentos relevantes
├── relatorios/            # Relatórios gerados
│   ├── relatorio_20240723_143022.json
│   ├── relatorio_20240723_143022.csv
│   └── relatorio_20240723_143022.html
├── downloaded_hashes.json # Controle de duplicatas
└── archive_scraper.log    # Log de execução
```

## 🔧 Configuração Avançada

### Parâmetros Principais
```python
scraper = ArchiveScraper(
    output_dir="documentos_pf",    # Diretório de saída
    max_workers=5                  # Downloads simultâneos
)
```

### Customização de Queries
```python
# Adicionar queries personalizadas
custom_queries = [
    'site:cebraspe.org.br "concurso" "pf" 2024 filetype:pdf',
    'cespe "prova" "agente" "gabarito" filetype:pdf'
]

for query in custom_queries:
    results = scraper.search_archive_api(query)
    # Processar resultados...
```

## 📊 Relatórios Gerados

### Relatório JSON
Contém dados estruturados de todos os documentos:
```json
{
  "url": "https://archive.org/download/...",
  "filename": "prova_agente_pf_2023.pdf",
  "category": "provas",
  "size": 2547832,
  "hash": "d41d8cd98f00b204e9800998ecf8427e",
  "download_time": "2024-07-23T14:30:22"
}
```

### Relatório HTML
Interface visual interativa com:
- Estatísticas gerais
- Tabela filterable
- Links para documentos originais
- Distribuição por categoria

## 🔍 Estratégias de Busca

### 1. API do Archive.org
- Busca baseada em metadados
- Suporte a operadores avançados
- Paginação automática

### 2. Wayback Machine
- Acesso a snapshots históricos
- Busca por domínios específicos
- Filtros por tipo de arquivo

### 3. Scraping Direto
- Navegação por sites ativos
- Extração de links para PDFs
- Busca em profundidade configurável

### 4. URLs Ocultas
- Padrões comuns de estrutura de sites
- Tentativas com anos diferentes
- Verificação de existência de arquivos

## ⚡ Otimizações

### Rate Limiting Inteligente
- Delay adaptativo baseado em resposta do servidor
- Respeita limites de requisições
- Evita bloqueios por IP

### Downloads Paralelos
- ThreadPoolExecutor para eficiência
- Controle de concorrência
- Tratamento de timeouts

### Detecção de Duplicatas
- Hash MD5 para identificação única
- Cache persistente entre execuções
- Economia de largura de banda

## 🛡️ Tratamento de Erros

### Tipos de Erro Tratados
- Timeouts de conexão
- Rate limiting (429)
- Arquivos não encontrados (404)
- Erros de parsing
- Problemas de escrita em disco

### Logs Detalhados
```
2024-07-23 14:30:22 - INFO - Iniciando busca completa...
2024-07-23 14:30:25 - INFO - Encontrados 45 snapshots para cebraspe.org.br
2024-07-23 14:30:28 - WARNING - Rate limit atingido. Aumentando delay para 2.0s
2024-07-23 14:30:30 - INFO - Baixado: prova_agente_2023.pdf (2.43 MB)
2024-07-23 14:30:35 - ERROR - Erro ao baixar http://...: Connection timeout
```

## 📈 Monitoramento

### Barras de Progresso
- Progresso de queries da API
- Status de downloads
- Processamento de snapshots

### Estatísticas em Tempo Real
- Documentos encontrados
- Tamanho total baixado
- Taxa de sucesso

## ⚖️ Considerações Legais

### Uso Responsável
- ✅ Respeita robots.txt
- ✅ Implementa rate limiting
- ✅ Não sobrecarrega servidores
- ✅ Acessa apenas conteúdo público

### Termos de Uso
- Conteúdo do Archive.org é público
- Documentos governamentais são de domínio público
- Use apenas para fins educacionais/informativos

## 🔧 Resolução de Problemas

### Erros Comuns

#### "ModuleNotFoundError"
```bash
pip install -r requirements.txt
```

#### "Rate limit exceeded"
O script automaticamente aumenta o delay. Aguarde ou reduza `max_workers`.

#### "Permission denied"
Verifique permissões do diretório de saída:
```bash
chmod 755 documentos_pf/
```

#### Downloads lentos
- Reduza `max_workers`
- Verifique conexão com internet
- Considere executar em horários de menor tráfego

### Logs de Debug
Para mais detalhes, edite o nível de logging:
```python
logging.basicConfig(level=logging.DEBUG)
```

## 🚀 Melhorias Futuras

### Recursos Planejados
- [ ] Interface gráfica (GUI)
- [ ] Busca incremental (apenas novos documentos)
- [ ] Classificação automática por tipo de concurso
- [ ] Extração de texto dos PDFs
- [ ] Busca por conteúdo dentro dos documentos
- [ ] Notificações por email
- [ ] Dashboard web em tempo real

### Contribuições
Contribuições são bem-vindas! Áreas de interesse:
- Otimização de performance
- Novos tipos de documento
- Melhorias na interface
- Testes automatizados

## 📞 Suporte

### FAQ

**Q: O script pode ser interrompido e retomado?**
A: Sim, ele mantém controle de downloads já realizados via hash.

**Q: Quantos documentos posso esperar encontrar?**
A: Depende do período, mas geralmente centenas de documentos históricos.

**Q: O script funciona apenas para Polícia Federal?**
A: Sim, é especializado, mas pode ser adaptado para outros órgãos.

**Q: Posso modificar as queries de busca?**
A: Sim, edite o método `generate_search_queries()`.

### Contato
Para dúvidas técnicas ou melhorias, abra uma issue no repositório.

---

**⚠️ Aviso**: Use este script responsavelmente e de acordo com os termos de uso dos sites acessados. O objetivo é facilitar o acesso a informações públicas para fins educacionais.