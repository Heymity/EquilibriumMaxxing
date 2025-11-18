# Para clonar o projeto
Execute os seguintes comandos:

```bash
git clone https://github.com/Heymity/EquilibriumMaxxing.git
```

Após terminada a clonagem, entre na pasta criada:

```bash
cd EquilibriumMaxxing
```

E por fim execute:

```bash
git submodule update --init --recursive
```

para poder compilar o código do micro controlador.

## Realizar a build do código do micro controlador

entre na pasta SimpleADC_UART e crie dentro dela uma crie uma pasta chamada build e entre nela

```bash
cd EquilibriumMaxxing/SimpleADC_UART
mkdir build
cd build
```

dentro dela execute uma vez o seguinte comando:

```bash
cmake ..
```

Agora toda vez que desejar compilar o código simplesmente execute:


```bash
make
```
e conecte a placa no computador via USB segurando o botão BOOTSEL. Arraste o arquivo .uf2 da pasta build para a pasta aberta pelo microcontrolador.
