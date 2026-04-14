---
layout: chapter
order: 1120000
number: '1.12'
title: Tipos de dados em Java
---

Em Java, existem dois grandes grupos de tipos de dados: **tipos primitivos** e **tipos de referência**. Essa distinção define como os dados são armazenados em memória, como são passados para métodos e como operações sobre eles se comportam.
### **Exemplo conceitual**

```
int count = 10;
User user = new User("Alice");
```
### **Explicação linha a linha**

```
int count = 10;
```

Declara uma variável de tipo primitivo. O valor 10 é armazenado diretamente na variável, sem referência a um objeto.

```
User user = new User("Alice");
```

Declara uma variável de tipo de referência. A variável user armazena uma referência para um objeto criado no heap, não o objeto em si.

Tipos primitivos representam valores simples e têm comportamento previsível e eficiente. Tipos de referência representam objetos e compartilham o modelo de memória baseado em referências, o que impacta atribuição, passagem de parâmetros e mutabilidade.