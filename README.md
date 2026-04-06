# BlazeDemo Performance

Projeto de performance para o fluxo de compra de passagem aerea no [BlazeDemo](https://www.blazedemo.com/), usando JMeter em Docker.

## Escopo

- Cenario: compra de passagem aerea com sucesso.
- Criterio de aceitacao: 250 requisicoes por segundo com p90 abaixo de 2 segundos.
- Perfis entregues:
  - teste de carga
  - teste de pico

## Estrutura

- `jmeter/` contem o plano `.jmx`
- `scripts/run-jmeter.ps1` faz o `docker build` e executa os perfis
- `config/log4j2-console.xml` desliga o appender de arquivo padrao do JMeter
- `reports/` recebe os relatorios gerados pelo JMeter

## Pre-requisitos

- Docker instalado localmente
- GitHub Actions com suporte a containers

## Como executar localmente

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

Se a imagem ja tiver sido buildada e voce quiser reaproveitar:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\run-jmeter.ps1 -Mode both -SkipBuild
```

O script executa:

1. `docker build -t blazedemo-performance:jmeter-5.6.3 .`
2. `docker run` para o teste de carga
3. `docker run` para o teste de pico

Saidas geradas:

- `reports/load/results.jtl`
- `reports/load/html-report/index.html`
- `reports/spike/results.jtl`
- `reports/spike/html-report/index.html`

## GitHub Actions

O fluxo em `.github/workflows/performance.yml` executa em `ubuntu-latest`, faz `docker build` da imagem do projeto, roda os perfis `load` e `spike` dentro do container e publica `reports/load/**` e `reports/spike/**` como artefato.

Como executar no GitHub:

1. Suba o repositório para o GitHub.
2. Abra a aba `Actions`.
3. Selecione o workflow `performance`.
4. Clique em `Run workflow` para executar manualmente.

O workflow tambem roda automaticamente em `push` na branch `main` e em `pull_request`.

## Criterio de aceitacao

O objetivo deste teste nao e apenas "carregar" a aplicacao, mas confirmar que o fluxo de compra continua util sob pressao. Para isso, o criterio de aceitacao e:

- `250 requisicoes por segundo` sustentadas
- `90th percentile` de tempo de resposta abaixo de `2 segundos`
- `Error %` igual a `0` ou muito proximo de `0`

### Quando o criterio e satisfatorio

O criterio e considerado satisfatorio quando o teste consegue manter a vazao alvo de `250 req/s` e, ao mesmo tempo, o `90th percentile` fica abaixo de `2 s`. Nesse caso, a maioria esmagadora das requisicoes responde dentro da janela esperada, o fluxo de compra permanece consistente e nao ha indicio de degradacao relevante do sistema.

### Quando o criterio nao e satisfatorio

O criterio e considerado nao satisfatorio quando qualquer um destes pontos ocorre:

- a vazao fica abaixo de `250 req/s`
- o `90th percentile` ultrapassa `2 s`
- o volume de erros deixa de ser nulo ou aceitavel

Isso indica que o sistema nao conseguiu sustentar o nivel minimo de desempenho esperado para uma experiencia estavel. Se a vazao cair, o ambiente nao suporta a demanda. Se o `p90` subir acima de `2 s`, mesmo que a media pareca boa, uma parcela relevante dos usuarios vai perceber lentidao. Se houver erro, o fluxo de compra deixa de ser confiavel.

### Como interpretar o resultado

- Se a vazao for `>= 250 req/s` e o `p90 < 2 s`, o criterio foi atendido.
- Se a vazao for menor que `250 req/s`, o criterio foi reprovado.
- Se o `p90 >= 2 s`, o criterio foi reprovado.
- Se houver erros recorrentes, o criterio tambem deve ser tratado como reprovado.

## Relatorio de execucao

Este ambiente nao executa o Docker nem publica no GitHub, entao os scripts foram preparados, mas os numeros de execucao nao foram gerados aqui.

Quando o teste for executado, a conclusao deve ser preenchida com base em:

- vazao obtida
- p90 medido
- taxa de erro
- estabilidade da confirmacao de compra

## Consideracoes

- O BlazeDemo e um site publico de demonstracao; resultados reais variam conforme a rede e a capacidade do servidor.
- O plano foi parametrizado para suportar carga e pico com o mesmo alvo de vazao.
- O fluxo termina na pagina de confirmacao com a mensagem `Thank you for your purchase today!`.
