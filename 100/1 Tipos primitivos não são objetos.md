---
layout: chapter
order: 1120100
number: 1.12.1
title: Tipos primitivos não são objetos
---

Um **tipo primitivo** não é um objeto. Ele representa apenas um valor único armazenado diretamente na memória, sem identidade, sem comportamento e sem referência associada. Primitivos existem para fornecer uma forma simples e eficiente de trabalhar com dados básicos.
### **Exemplo conceitual**

```
int a = 5;
int b = a;
```
### **Explicação linha a linha**

```
int a = 5;
```

Declara uma variável primitiva do tipo int e armazena diretamente o valor 5.

```
int b = a;
```

Copia o valor armazenado em a para b. Nenhuma referência é envolvida e nenhuma memória compartilhada é criada entre as variáveis.

Como primitivos não são objetos, eles não possuem métodos, não participam de herança e não podem ser null. Essa simplicidade é uma característica central do modelo de tipos do Java.