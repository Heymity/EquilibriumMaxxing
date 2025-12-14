# Equilibrim Maxxing

O Projeto Equilibrium Maxxing foi desenvolvido como parte da disciplina PCS3645 - Laboratório Digital 2, com a motivação extensionista de desenvolver Sistemas Digitais que auxiliam pessoas da Transtorno do Espectro Autista. 

O Nosso projeto visa desenvolver coordenação visão-motora e coordenação motora fina, consistindo de equilibrar um pêndulo invertido em posições especificas. Veja mais detalhes na curta apresentação abaixo no Youtube

https://youtu.be/-tbgzlC2d6Y


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

Os arquivos da montagem fisica ainda não está disponível nesse repositório, mas se for de interesse, por favor crie um issue.
