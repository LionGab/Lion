#!/usr/bin/env python3
"""
Script de configuração e instalação para o Archive.org PF Scraper
"""

import os
import sys
import subprocess
import importlib

def check_python_version():
    """Verifica se a versão do Python é compatível"""
    if sys.version_info < (3, 7):
        print("❌ Python 3.7 ou superior é necessário!")
        print(f"Versão atual: {sys.version}")
        return False
    print(f"✅ Python {sys.version_info.major}.{sys.version_info.minor} detectado")
    return True

def install_requirements():
    """Instala as dependências necessárias"""
    requirements = [
        "requests>=2.31.0",
        "beautifulsoup4>=4.12.2", 
        "pandas>=2.0.3",
        "tqdm>=4.66.1",
        "urllib3>=2.0.4",
        "lxml>=4.9.3"
    ]
    
    print("📦 Instalando dependências...")
    
    for requirement in requirements:
        try:
            print(f"  Instalando {requirement}...")
            subprocess.check_call([
                sys.executable, "-m", "pip", "install", requirement
            ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            print(f"  ✅ {requirement} instalado com sucesso")
        except subprocess.CalledProcessError:
            print(f"  ❌ Erro ao instalar {requirement}")
            return False
    
    return True

def verify_installation():
    """Verifica se todas as bibliotecas foram instaladas corretamente"""
    modules = {
        'requests': 'Biblioteca para requisições HTTP',
        'bs4': 'BeautifulSoup para parsing HTML',
        'pandas': 'Pandas para manipulação de dados',
        'tqdm': 'Barra de progresso',
        'urllib3': 'Utilitários para URLs'
    }
    
    print("\n🔍 Verificando instalação...")
    
    for module, description in modules.items():
        try:
            importlib.import_module(module)
            print(f"  ✅ {module}: {description}")
        except ImportError:
            print(f"  ❌ {module}: {description} - NÃO INSTALADO")
            return False
    
    return True

def create_sample_config():
    """Cria arquivo de configuração de exemplo"""
    config_content = """# Configurações do Archive.org PF Scraper

# Diretório onde os arquivos serão salvos
OUTPUT_DIR = "documentos_pf"

# Número máximo de downloads simultâneos
MAX_WORKERS = 5

# Delay entre requisições (segundos)
RATE_LIMIT_DELAY = 1.0

# Domínios a serem pesquisados
SEARCH_DOMAINS = [
    "cebraspe.org.br",
    "cespe.unb.br"
]

# Palavras-chave para busca
KEYWORDS = [
    "polícia federal",
    "agente",
    "escrivão", 
    "papiloscopista",
    "delegado",
    "prova",
    "edital",
    "gabarito"
]

# Anos para busca (intervalo)
SEARCH_YEARS = range(2010, 2025)

# Tipos de arquivo para busca
FILE_TYPES = [".pdf", ".doc", ".docx"]

# Tamanho máximo de arquivo para download (MB)
MAX_FILE_SIZE = 50
"""
    
    with open("config_scraper.py", "w", encoding="utf-8") as f:
        f.write(config_content)
    
    print("  ✅ Arquivo de configuração criado: config_scraper.py")

def run_installation():
    """Executa o processo completo de instalação"""
    print("🚀 Iniciando configuração do Archive.org PF Scraper...\n")
    
    # Verificar Python
    if not check_python_version():
        return False
    
    # Instalar dependências
    if not install_requirements():
        print("\n❌ Falha na instalação das dependências!")
        return False
    
    # Verificar instalação
    if not verify_installation():
        print("\n❌ Falha na verificação da instalação!")
        return False
    
    # Criar configuração
    create_sample_config()
    
    print("\n✅ Configuração concluída com sucesso!")
    print("\n📝 Próximos passos:")
    print("1. Execute: python archive_pf_scraper.py")
    print("2. Configure os parâmetros conforme necessário")
    print("3. Os arquivos serão salvos no diretório especificado")
    print("\n⚠️  IMPORTANTE:")
    print("- Use com responsabilidade e respeite os termos de uso")
    print("- O script implementa rate limiting para evitar sobrecarga")
    print("- Verifique regularmente os logs para monitorar o progresso")
    
    return True

if __name__ == "__main__":
    success = run_installation()
    if not success:
        sys.exit(1)