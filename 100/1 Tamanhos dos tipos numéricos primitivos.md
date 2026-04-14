---
layout: chapter
order: 1120400
number: 1.12.4
title: Tamanhos dos tipos numéricos primitivos
---

Os tipos numéricos primitivos em Java possuem **tamanhos fixos**, definidos pela linguagem, o que garante comportamento consistente em qualquer plataforma. Na prática, o tipo int é suficiente para a maioria dos cenários e deve ser a escolha padrão, a menos que exista uma razão clara para usar um tipo menor (memória) ou maior (intervalo de valores).
### **Exemplo conceitual**

```
int count = 1_000;
long total = 10_000_000_000L;
```
### **Explicação linha a linha**

```
int count = 1_000;
```

Utiliza o tipo int, que é eficiente, amplamente suportado pela JVM e adequado para a maioria das operações aritméticas do dia a dia.

```
long total = 10_000_000_000L;
```

Utiliza o tipo long para armazenar um valor que excede o intervalo do int. O sufixo L é obrigatório para literais desse tipo.
### **Tabela de tamanhos dos tipos primitivos (Java / JDK 21)**

|**Tipo primitivo**|**Categoria**|**Tamanho (bits)**|**Observações**|
|---|---|---|---|
|byte|Inteiro|8|Intervalo pequeno, raramente usado para cálculos|
|short|Inteiro|16|Pouco usado em código moderno|
|int|Inteiro|32|**Escolha padrão para inteiros**|
|long|Inteiro|64|Usado para valores muito grandes|
|float|Ponto flutuante|32|Precisão limitada|
|double|Ponto flutuante|64|**Escolha padrão para decimais**|
|char|Caractere|16|Representa um código UTF-16|
|boolean|Lógico|_não especificado_|Tamanho depende da JVM|
### **Observação importante**
Usar tipos menores que int raramente traz benefícios práticos e pode até gerar código mais complexo devido a conversões implícitas. Por esse motivo, **int é o tipo inteiro recomendado na maioria dos casos**, enquanto long deve ser reservado para situações em que o intervalo do int não é suficiente.

Mais adiante, veremos como esses tamanhos influenciam performance, conversões e interoperabilidade com APIs.