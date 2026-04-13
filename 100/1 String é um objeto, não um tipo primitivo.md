Em Java, String **não** é um tipo primitivo; ela é uma classe. Isso significa que valores do tipo String são objetos, armazenados no heap e manipulados por meio de referências, mesmo que a linguagem ofereça uma sintaxe conveniente para sua criação.
### **Exemplo conceitual**

```
String text = "Hello";
```
### **Explicação linha a linha**

```
String text = "Hello";
```

Declara uma variável do tipo String. Apesar da sintaxe simples, um objeto do tipo String é criado e armazenado no heap, e a variável text contém apenas uma referência para esse objeto.

Por ser um objeto, String possui métodos, pode ser passada como referência e segue as regras de memória aplicáveis a tipos de referência. Detalhes como imutabilidade e _string pool_ serão abordados mais adiante.