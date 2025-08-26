def tipo_questao(texto):
    if "não é" in texto.lower() or "exceto" in texto.lower():
        return "Lógica Inversa"
    if "assinale a correta" in texto.lower():
        return "Literal / Positiva"
    return "Neutra"

# Teste
print(tipo_questao("Assinale a alternativa que não é verdadeira."))

# Testes adicionais
exemplos = [
    "Assinale a alternativa que não é verdadeira.",
    "Marque a opção correta, exceto:",
    "Assinale a correta sobre direito constitucional.",
    "Qual das alternativas abaixo está incorreta?",
    "Todas as opções são verdadeiras, exceto uma.",
    "Considerando a legislação vigente, assinale a correta."
]

print("\n=== ANÁLISE DE QUESTÕES ===")
for exemplo in exemplos:
    resultado = tipo_questao(exemplo)
    print(f"Tipo: {resultado:15} | Texto: {exemplo}")