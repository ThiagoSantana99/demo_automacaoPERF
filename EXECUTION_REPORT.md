# Execution Report

## Resumo

Os testes de carga e de pico foram executados para validar o fluxo de compra do BlazeDemo contra o criterio de aceitacao do projeto:

- 250 requisicoes por segundo sustentadas
- p90 abaixo de 2 segundos
- taxa de erro igual a 0 ou muito baixa

## Teste de carga

Resultado: nao satisfatorio.

Principais numeros do relatorio:

- Throughput total: `66,33 req/s`
- p90 total: `2829,9 ms`
- Erros: `0`

Conclusao:

O teste de carga nao atingiu a meta de vazao. Alem disso, o p90 ficou acima de 2 segundos. Mesmo sem erros, o resultado mostra que o sistema nao sustentou o nivel de desempenho esperado.

## Teste de pico

Resultado: nao satisfatorio.

Principais numeros do relatorio:

- Throughput total: `79,42 req/s`
- p90 total: `69122,7 ms`
- Erros: `23`

Conclusao:

O teste de pico ficou muito abaixo da vazao esperada, teve aumento forte de latencia e ainda registrou erros. Isso indica degradacao clara do sistema sob estresse.

## Conclusao final

Nenhum dos dois testes atendeu ao criterio de aceitacao. O teste de carga falhou principalmente por vazao baixa e p90 acima do limite. O teste de pico falhou por vazao baixa, latencia muito alta e presenca de erros.


Reports Gerados via Workflow:
https://thiagosantana99.github.io/demo_automacaoPERF/reports/


Reports Gerados execução local: https://github.com/ThiagoSantana99/demo_automacaoPERF/tree/main/reports