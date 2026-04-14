---
layout: chapter
order: 1120300
number: 1.12.3
title: Tipos numéricos com sinal
---

Os tipos numéricos primitivos em Java são **com sinal** (_signed_). Isso significa que parte dos bits disponíveis é reservada para representar valores negativos. Como consequência, o intervalo de valores possíveis é dividido entre números negativos e positivos. Por exemplo, um byte utiliza 8 bits, permitindo representar valores de -128 a 127.
### **Exemplo conceitual**

```
byte small = -128;
int value = 2_147_483_647;
```
### **Explicação linha a linha**

```
byte small = -128;
```

Atribui o menor valor possível a um byte. Metade do intervalo é dedicada a valores negativos.

```
int value = 2_147_483_647;
```

Atribui o maior valor possível a um int. Esse limite é determinado pela quantidade de bits reservados ao tipo.
### **Intervalos dos tipos numéricos primitivos**

| **Tipo primitivo** | **Bits** | **Intervalo mínimo**       | **Intervalo máximo**      |
| ------------------ | -------- | -------------------------- | ------------------------- |
| byte               | 8        | -128                       | 127                       |
| short              | 16       | -32.768                    | 32.767                    |
| int                | 32       | -2.147.483.648             | 2.147.483.647             |
| long               | 64       | -9.223.372.036.854.775.808 | 9.223.372.036.854.775.807 |
| float              | 32       | ≈ ±1.4 × 10⁻⁴⁵             | ≈ ±3.4 × 10³⁸             |
| double             | 64       | ≈ ±4.9 × 10⁻³²⁴            | ≈ ±1.8 × 10³⁰⁸            |
### **Observação importante**
O uso de tipos com sinal permite representar valores negativos de forma eficiente, mas reduz o valor máximo positivo possível. Esse comportamento é padronizado no Java e independe do sistema operacional ou arquitetura, garantindo previsibilidade em qualquer ambiente.