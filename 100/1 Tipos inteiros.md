Os tipos byte, short, int e long são **tipos primitivos inteiros**, ou seja, representam números sem parte decimal. Cada um desses tipos ocupa uma quantidade diferente de memória e possui um intervalo específico de valores possíveis.
### **Exemplo conceitual**

```
byte a = 10;
short b = 100;
int c = 1_000;
long d = 10_000L;
```
### **Explicação linha a linha**

```
byte a = 10;
```

Declara uma variável do tipo byte, adequada para armazenar valores inteiros pequenos.

```
short b = 100;
```

Declara uma variável do tipo short, que possui um intervalo maior que o byte.

```
int c = 1_000;
```

Declara uma variável do tipo int, o tipo inteiro mais utilizado em Java.

```
long d = 10_000L;
```

Declara uma variável do tipo long. O sufixo L indica explicitamente que o valor literal é do tipo long.

A escolha entre esses tipos depende do intervalo de valores necessário e de considerações de memória e desempenho.