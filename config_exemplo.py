#!/usr/bin/env python3
"""
Arquivo de configuração exemplo para o Archive.org PF Scraper
Copie este arquivo para config.py e ajuste conforme necessário
"""

# =============================================================================
# CONFIGURAÇÕES BÁSICAS
# =============================================================================

# Diretório onde os arquivos serão salvos
OUTPUT_DIR = "documentos_pf"

# Número máximo de downloads simultâneos (1-10 recomendado)
MAX_WORKERS = 5

# Delay inicial entre requisições em segundos (mínimo 0.5)
INITIAL_RATE_LIMIT_DELAY = 1.0

# =============================================================================
# DOMÍNIOS E FONTES
# =============================================================================

# Domínios principais para busca
SEARCH_DOMAINS = [
    "cebraspe.org.br",
    "cespe.unb.br",
    "pciconcursos.com.br",  # Adicional
    "concursosfcc.com.br"   # Adicional
]

# URLs base para busca de PDFs ocultos
BASE_URLS = [
    "https://cebraspe.org.br/concursos/",
    "https://cespe.unb.br/concursos/",
    "https://www.cebraspe.org.br/arquivos/",
    "https://www.cespe.unb.br/web/guest/"
]

# =============================================================================
# PALAVRAS-CHAVE E TERMOS DE BUSCA
# =============================================================================

# Termos relacionados à Polícia Federal
PF_TERMS = [
    "polícia federal",
    "policia federal", 
    "pf",
    "dpf",
    "departamento de polícia federal"
]

# Cargos da Polícia Federal
CARGO_TERMS = [
    "agente",
    "agente de polícia federal",
    "escrivão",
    "escrivao",
    "escrivão de polícia federal",
    "papiloscopista",
    "papiloscopista da polícia federal",
    "delegado",
    "delegado de polícia federal",
    "perito criminal federal",
    "perito"
]

# Tipos de documento
DOCUMENT_TERMS = [
    "prova",
    "edital",
    "gabarito",
    "gabarito preliminar",
    "gabarito definitivo",
    "resultado",
    "classificação",
    "convocação",
    "cronograma",
    "retificação",
    "errata"
]

# Palavras-chave adicionais
ADDITIONAL_KEYWORDS = [
    "concurso público",
    "concurso",
    "seleção",
    "processo seletivo",
    "certame",
    "abertura",
    "inscrição",
    "homologação"
]

# =============================================================================
# FILTROS TEMPORAIS
# =============================================================================

# Intervalo de anos para busca
SEARCH_YEARS = list(range(2005, 2025))  # 2005 a 2024

# Anos específicos com concursos conhecidos
PRIORITY_YEARS = [2024, 2023, 2021, 2018, 2014, 2012, 2009]

# =============================================================================
# TIPOS DE ARQUIVO
# =============================================================================

# Extensões de arquivo para busca
FILE_EXTENSIONS = [
    ".pdf",
    ".doc", 
    ".docx",
    ".txt"
]

# Tipos MIME aceitos
ACCEPTED_MIME_TYPES = [
    "application/pdf",
    "application/msword",
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    "text/plain"
]

# Tamanho máximo de arquivo em MB
MAX_FILE_SIZE_MB = 50

# Tamanho mínimo de arquivo em KB (evitar arquivos muito pequenos)
MIN_FILE_SIZE_KB = 10

# =============================================================================
# CONFIGURAÇÕES AVANÇADAS DE BUSCA
# =============================================================================

# Profundidade máxima para scraping de páginas
MAX_SCRAPING_DEPTH = 3

# Número máximo de páginas de resultados da API
MAX_API_PAGES = 10

# Número de resultados por página da API
API_RESULTS_PER_PAGE = 50

# Timeout para requisições em segundos
REQUEST_TIMEOUT = 60

# Timeout para downloads em segundos
DOWNLOAD_TIMEOUT = 300

# =============================================================================
# PADRÕES DE URL PARA BUSCA DE PDFS OCULTOS
# =============================================================================

# Padrões comuns de estrutura de URLs
URL_PATTERNS = [
    "concursos/pf_{year}/",
    "concursos/policia_federal_{year}/",
    "concursos/{year}/pf/",
    "provas/pf/{year}/",
    "editais/pf/{year}/",
    "gabaritos/pf/{year}/",
    "arquivos/concursos/pf/",
    "storage/concursos/policia_federal/",
    "files/provas/pf/",
    "downloads/pf/{year}/",
    "docs/concursos/pf/",
    "pdf/pf/{year}/"
]

# Nomes comuns de arquivos
COMMON_FILENAMES = [
    "prova_agente_pf_{year}.pdf",
    "prova_agente_{year}.pdf",
    "prova_pf_agente_{year}.pdf",
    "edital_pf_{year}.pdf",
    "edital_abertura_pf_{year}.pdf",
    "edital_policia_federal_{year}.pdf",
    "gabarito_pf_{year}.pdf",
    "gabarito_preliminar_pf_{year}.pdf",
    "gabarito_definitivo_pf_{year}.pdf",
    "gabarito_agente_pf_{year}.pdf",
    "prova_escrivao_pf_{year}.pdf",
    "prova_escrivao_{year}.pdf",
    "prova_papiloscopista_pf_{year}.pdf",
    "prova_papiloscopista_{year}.pdf",
    "prova_delegado_pf_{year}.pdf",
    "prova_delegado_{year}.pdf",
    "edital_retificacao_pf_{year}.pdf",
    "resultado_pf_{year}.pdf",
    "cronograma_pf_{year}.pdf"
]

# =============================================================================
# CONFIGURAÇÕES DE CATEGORIZAÇÃO
# =============================================================================

# Palavras-chave para categorizar como "provas"
PROVA_KEYWORDS = [
    "prova", "teste", "questão", "questao", "caderno", "exame"
]

# Palavras-chave para categorizar como "editais"
EDITAL_KEYWORDS = [
    "edital", "abertura", "retificação", "retificacao", "errata", 
    "cronograma", "convocação", "convocacao"
]

# Palavras-chave para categorizar como "gabaritos"
GABARITO_KEYWORDS = [
    "gabarito", "resposta", "resultado", "correção", "correcao"
]

# =============================================================================
# CONFIGURAÇÕES DE RELATÓRIO
# =============================================================================

# Formatos de relatório a serem gerados
REPORT_FORMATS = ["json", "csv", "html"]

# Incluir dados detalhados nos relatórios
INCLUDE_DETAILED_STATS = True

# Incluir informações de hash nos relatórios
INCLUDE_HASH_INFO = True

# Incluir URLs originais nos relatórios
INCLUDE_ORIGINAL_URLS = True

# =============================================================================
# CONFIGURAÇÕES DE LOG
# =============================================================================

# Nível de log (DEBUG, INFO, WARNING, ERROR, CRITICAL)
LOG_LEVEL = "INFO"

# Arquivo de log
LOG_FILE = "archive_scraper.log"

# Incluir timestamp detalhado nos logs
DETAILED_LOGGING = True

# Logs separados por categoria
SEPARATE_CATEGORY_LOGS = False

# =============================================================================
# CONFIGURAÇÕES DE PERFORMANCE
# =============================================================================

# Cache de resultados de busca (em horas)
SEARCH_CACHE_HOURS = 24

# Retry automático em caso de falha
AUTO_RETRY_FAILED = True

# Número máximo de tentativas por download
MAX_RETRY_ATTEMPTS = 3

# Usar compressão para downloads quando disponível
USE_COMPRESSION = True

# =============================================================================
# CONFIGURAÇÕES EXPERIMENTAIS
# =============================================================================

# Usar busca semântica (experimental)
USE_SEMANTIC_SEARCH = False

# Extrair texto dos PDFs baixados
EXTRACT_PDF_TEXT = False

# Buscar em redes sociais e fóruns
SEARCH_SOCIAL_MEDIA = False

# Usar proxy para requisições (se necessário)
USE_PROXY = False
PROXY_CONFIG = {
    "http": None,
    "https": None
}

# =============================================================================
# QUERIES PERSONALIZADAS
# =============================================================================

# Queries adicionais específicas do usuário
CUSTOM_QUERIES = [
    'site:cebraspe.org.br "polícia federal" "2024" filetype:pdf',
    'site:cespe.unb.br "concurso" "pf" "agente" filetype:pdf',
    '"prova" "gabarito" "polícia federal" cebraspe filetype:pdf',
    'cespe "edital" "policia federal" "abertura" filetype:pdf',
    # Adicione suas próprias queries aqui
]

# =============================================================================
# BLACKLIST E WHITELIST
# =============================================================================

# URLs ou padrões a serem ignorados
URL_BLACKLIST = [
    "login",
    "cadastro", 
    "admin",
    "sistema",
    "portal",
    "javascript:",
    "mailto:",
    "#"
]

# Apenas URLs que contenham estes termos (deixe vazio para desabilitar)
URL_WHITELIST = []

# Tamanhos de arquivo a serem ignorados (em bytes)
IGNORE_FILE_SIZES = [
    1024,  # 1KB - provavelmente arquivo vazio
    2048   # 2KB - provavelmente página de erro
]

# =============================================================================
# FUNÇÕES DE VALIDAÇÃO PERSONALIZADAS
# =============================================================================

def custom_url_validator(url: str) -> bool:
    """
    Função personalizada para validar URLs antes do download
    
    Args:
        url: URL a ser validada
        
    Returns:
        True se a URL deve ser processada, False caso contrário
    """
    # Exemplo: ignorar URLs com determinados padrões
    ignore_patterns = ["temp", "cache", "backup"]
    
    for pattern in ignore_patterns:
        if pattern in url.lower():
            return False
            
    return True

def custom_filename_generator(url: str, original_filename: str) -> str:
    """
    Função personalizada para gerar nomes de arquivo
    
    Args:
        url: URL original do arquivo
        original_filename: Nome original do arquivo
        
    Returns:
        Nome de arquivo personalizado
    """
    # Exemplo: adicionar prefixo baseado no domínio
    if "cebraspe" in url:
        return f"cebraspe_{original_filename}"
    elif "cespe" in url:
        return f"cespe_{original_filename}"
    
    return original_filename

# =============================================================================
# CONFIGURAÇÕES DE NOTIFICAÇÃO (OPCIONAL)
# =============================================================================

# Enviar email ao concluir busca
SEND_EMAIL_NOTIFICATION = False

EMAIL_CONFIG = {
    "smtp_server": "smtp.gmail.com",
    "smtp_port": 587,
    "sender_email": "",
    "sender_password": "",
    "recipient_email": "",
    "subject": "Archive Scraper - Busca Concluída"
}

# Enviar notificação no sistema
SEND_SYSTEM_NOTIFICATION = True

# =============================================================================
# CONFIGURAÇÕES DE BACKUP
# =============================================================================

# Fazer backup dos arquivos de configuração
BACKUP_CONFIG_FILES = True

# Diretório de backup
BACKUP_DIR = "backup"

# Manter histórico de downloads
KEEP_DOWNLOAD_HISTORY = True

# Arquivo de histórico
HISTORY_FILE = "download_history.json"