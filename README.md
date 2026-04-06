# BlazeDemo Performance

Projeto de performance para o fluxo de compra de passagem aerea no [BlazeDemo](https://www.blazedemo.com/), usando JMeter.

## Escopo

- Cenario: compra de passagem aerea com sucesso.
- Criterio de aceitacao: 250 requisicoes por segundo com p90 abaixo de 2 segundos.
- Perfis entregues:
  - teste de carga
  - teste de pico

## Estrutura

- `jmeter/` contem o plano `.jmx`
- `data/passengers.csv` contem a massa de dados
- `scripts/run-jmeter.ps1` executa os perfis e gera os relatorios HTML do JMeter

## Pre-requisitos

- Java 8 ou superior
- Apache JMeter 5.6 ou superior instalado localmente
- `JMETER_HOME` configurado, ou `jmeter.bat` disponivel no `PATH`

## Como executar

Executar os dois perfis:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\run-jmeter.ps1 -Mode both
```

Executar apenas carga:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\run-jmeter.ps1 -Mode load
```

Executar apenas pico:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\run-jmeter.ps1 -Mode spike
```

Se o JMeter estiver em outro caminho, informe o diretório raiz:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\run-jmeter.ps1 -Mode both -JmeterHome "C:\apache-jmeter-5.6.3"
```

Saidas geradas:

- `reports/load/results.jtl`
- `reports/load/html-report/index.html`
- `reports/spike/results.jtl`
- `reports/spike/html-report/index.html`

## GitHub Actions

O fluxo em `.github/workflows/performance.yml` executa em `windows-latest`, instala o JMeter, roda os perfis `load` e `spike` e publica `reports/load/**` e `reports/spike/**` como artefato.

Como executar no GitHub:

1. Suba o repositório para o GitHub.
2. Abra a aba `Actions`.
3. Selecione o workflow `performance`.
4. Clique em `Run workflow` para executar manualmente.

O workflow tambem roda automaticamente em `push` na branch `main` e em `pull_request`.

## Como validar o criterio

No relatorio HTML do JMeter, verifique:

- `90th percentile` menor que `2000 ms`
- `Throughput` proximo de `250 req/s`
- `Error %` igual a `0`

Se o throughput ficar abaixo da meta, o teste nao atende ao criterio, mesmo com p90 baixo. Se o p90 passar de `2 s`, o criterio tambem falha, mesmo com vazao alta.

## Relatorio de execucao

Este ambiente nao possui JMeter instalado e nao permite publicar no GitHub, entao os scripts foram preparados, mas os numeros de execucao nao foram gerados aqui.

Quando o teste for executado, a conclusao deve ser preenchida com base em:

- vazao obtida
- p90 medido
- taxa de erro
- estabilidade da confirmacao de compra

## Consideracoes

- O BlazeDemo e um site publico de demonstracao; resultados reais variam conforme a rede e a capacidade do servidor.
- O plano foi parametrizado para suportar carga e pico com o mesmo alvo de vazao.
- O fluxo termina na pagina de confirmacao com a mensagem `Thank you for your purchase today!`.
