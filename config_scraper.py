# Configurações do Archive.org PF Scraper

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
