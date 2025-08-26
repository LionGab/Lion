import re
from typing import Dict, List, Tuple

class ClassificadorQuestoes:
    """
    Classificador avançado para tipos de questões de concurso
    Útil para análise de provas da Polícia Federal e outros concursos
    """
    
    def __init__(self):
        # Padrões para lógica inversa (negativa)
        self.padroes_inversa = [
            r'\bnão\s+é\b', r'\bnão\s+está\b', r'\bnão\s+pode\b',
            r'\bexceto\b', r'\bsalvo\b', r'\bcom\s+exceção\b',
            r'\bincorreta?\b', r'\bfalsa?\b', r'\binválida?\b',
            r'\berrada?\b', r'\binadequada?\b', r'\binapropriada?\b',
            r'\bnão\s+se\s+aplica\b', r'\bnão\s+corresponde\b',
            r'\bque\s+não\b', r'\bmenor\s+número\b', r'\bimpossível\b'
        ]
        
        # Padrões para lógica positiva
        self.padroes_positiva = [
            r'\bassinale\s+a\s+correta\b', r'\bmarque\s+a\s+correta\b',
            r'\bindique\s+a\s+correta\b', r'\bselecione\s+a\s+correta\b',
            r'\bverdadeira?\b', r'\bcorreta?\b', r'\bválida?\b',
            r'\badequada?\b', r'\bapropriada?\b', r'\bpertinente\b',
            r'\bde\s+acordo\s+com\b', r'\bconforme\b'
        ]
        
        # Padrões para questões de completar
        self.padroes_completar = [
            r'\bcomplete\b', r'\bpreencha\b', r'\bfalta\b',
            r'____+', r'\.\.\.\.*', r'\bsequência\b'
        ]
        
        # Padrões para assertivas/afirmações
        self.padroes_assertiva = [
            r'\banalise\s+as\s+afirmações\b', r'\bjulgue\s+os\s+itens\b',
            r'\bavalie\s+as\s+proposições\b', r'\bcerto\s+ou\s+errado\b',
            r'\bverdadeiro\s+ou\s+falso\b', r'\bassertiva?\b'
        ]
    
    def tipo_questao(self, texto: str) -> Dict[str, any]:
        """
        Classifica o tipo de questão com base no texto
        
        Args:
            texto (str): Texto do enunciado da questão
            
        Returns:
            Dict com tipo, confiança e detalhes da classificação
        """
        texto_lower = texto.lower()
        resultado = {
            'tipo': 'Neutra',
            'confianca': 0.0,
            'detalhes': [],
            'texto_original': texto
        }
        
        # Verifica lógica inversa (prioridade alta)
        matches_inversa = []
        for padrao in self.padroes_inversa:
            if re.search(padrao, texto_lower):
                matches_inversa.append(padrao)
        
        if matches_inversa:
            resultado['tipo'] = 'Lógica Inversa'
            resultado['confianca'] = min(0.9, len(matches_inversa) * 0.3)
            resultado['detalhes'] = matches_inversa
            return resultado
        
        # Verifica questões de completar
        matches_completar = []
        for padrao in self.padroes_completar:
            if re.search(padrao, texto_lower):
                matches_completar.append(padrao)
        
        if matches_completar:
            resultado['tipo'] = 'Completar'
            resultado['confianca'] = min(0.8, len(matches_completar) * 0.4)
            resultado['detalhes'] = matches_completar
            return resultado
        
        # Verifica assertivas
        matches_assertiva = []
        for padrao in self.padroes_assertiva:
            if re.search(padrao, texto_lower):
                matches_assertiva.append(padrao)
        
        if matches_assertiva:
            resultado['tipo'] = 'Assertiva/Julgamento'
            resultado['confianca'] = min(0.8, len(matches_assertiva) * 0.4)
            resultado['detalhes'] = matches_assertiva
            return resultado
        
        # Verifica lógica positiva
        matches_positiva = []
        for padrao in self.padroes_positiva:
            if re.search(padrao, texto_lower):
                matches_positiva.append(padrao)
        
        if matches_positiva:
            resultado['tipo'] = 'Literal/Positiva'
            resultado['confianca'] = min(0.7, len(matches_positiva) * 0.3)
            resultado['detalhes'] = matches_positiva
            return resultado
        
        # Se chegou até aqui, é neutra
        resultado['confianca'] = 0.1
        return resultado
    
    def analisar_prova(self, questoes: List[str]) -> Dict[str, any]:
        """
        Analisa uma prova completa e gera estatísticas
        
        Args:
            questoes (List[str]): Lista com textos das questões
            
        Returns:
            Dict com estatísticas da prova
        """
        resultados = []
        tipos_count = {}
        
        for i, questao in enumerate(questoes, 1):
            resultado = self.tipo_questao(questao)
            resultado['numero'] = i
            resultados.append(resultado)
            
            tipo = resultado['tipo']
            tipos_count[tipo] = tipos_count.get(tipo, 0) + 1
        
        return {
            'total_questoes': len(questoes),
            'resultados': resultados,
            'estatisticas': tipos_count,
            'percentuais': {
                tipo: round((count / len(questoes)) * 100, 1) 
                for tipo, count in tipos_count.items()
            }
        }
    
    def salvar_relatorio(self, analise: Dict, arquivo: str = "relatorio_questoes.txt"):
        """Salva relatório da análise em arquivo"""
        with open(arquivo, 'w', encoding='utf-8') as f:
            f.write("=== RELATÓRIO DE ANÁLISE DE QUESTÕES ===\n\n")
            f.write(f"Total de questões: {analise['total_questoes']}\n\n")
            
            f.write("ESTATÍSTICAS POR TIPO:\n")
            for tipo, count in analise['estatisticas'].items():
                percentual = analise['percentuais'][tipo]
                f.write(f"  {tipo}: {count} questões ({percentual}%)\n")
            
            f.write("\n" + "="*50 + "\n")
            f.write("ANÁLISE DETALHADA POR QUESTÃO:\n\n")
            
            for resultado in analise['resultados']:
                f.write(f"Questão {resultado['numero']}:\n")
                f.write(f"  Tipo: {resultado['tipo']}\n")
                f.write(f"  Confiança: {resultado['confianca']:.1%}\n")
                f.write(f"  Texto: {resultado['texto_original'][:100]}...\n")
                if resultado['detalhes']:
                    f.write(f"  Padrões encontrados: {resultado['detalhes']}\n")
                f.write("\n")

# Exemplo de uso
if __name__ == "__main__":
    classificador = ClassificadorQuestoes()
    
    # Exemplos de questões típicas de concurso da PF
    questoes_exemplo = [
        "Assinale a alternativa que não é verdadeira sobre a Constituição Federal.",
        "Marque a opção correta sobre direitos fundamentais.",
        "Complete a lacuna: A Polícia Federal tem como função ______.",
        "Julgue os itens a seguir como certo ou errado.",
        "Todas as alternativas são corretas, exceto uma:",
        "Qual das opções abaixo está incorreta?",
        "De acordo com a legislação penal, assinale a correta:",
        "Analise as afirmações sobre processo penal:",
        "A sequência correta é:",
        "Considerando a doutrina majoritária, é verdadeiro afirmar que:"
    ]
    
    print("=== TESTE INDIVIDUAL ===")
    for questao in questoes_exemplo[:3]:
        resultado = classificador.tipo_questao(questao)
        print(f"Tipo: {resultado['tipo']:20} | Confiança: {resultado['confianca']:.1%} | {questao[:50]}...")
    
    print("\n=== ANÁLISE COMPLETA DA PROVA ===")
    analise = classificador.analisar_prova(questoes_exemplo)
    
    print(f"Total de questões: {analise['total_questoes']}")
    print("\nDistribuição por tipo:")
    for tipo, percentual in analise['percentuais'].items():
        count = analise['estatisticas'][tipo]
        print(f"  {tipo}: {count} questões ({percentual}%)")
    
    # Salvar relatório
    classificador.salvar_relatorio(analise)
    print(f"\nRelatório salvo em: relatorio_questoes.txt")