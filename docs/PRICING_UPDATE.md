# 📊 Atualização de Preços - Calculadora AWS Glue

## ✅ Verificação Realizada

A calculadora foi atualizada com base na página oficial de pricing da AWS Glue:
**Fonte:** https://aws.amazon.com/glue/pricing/

## 🔄 Mudanças Implementadas

### 1. Preços por Região

A calculadora agora suporta preços diferentes por região:

| Região | Preço por DPU-Hora | Observação |
|--------|-------------------|------------|
| us-east-1 (N. Virginia) | $0.44 | Preço padrão |
| us-east-2 (Ohio) | $0.44 | |
| us-west-1 (N. California) | $0.44 | |
| us-west-2 (Oregon) | $0.44 | |
| **sa-east-1 (São Paulo)** | **$0.60** | **Preço mais alto** |
| eu-west-1 (Ireland) | $0.44 | |
| eu-central-1 (Frankfurt) | $0.44 | |
| ap-southeast-1 (Singapore) | $0.44 | |

### 2. Valores Confirmados

✅ **Worker Types e DPUs:**
- G.025X = 0.25 DPU
- G.1X = 1 DPU
- G.2X = 2 DPUs
- G.4X = 4 DPUs
- G.8X = 8 DPUs

✅ **Faturamento:**
- Jobs ETL: Mínimo de 1 minuto, depois por segundo
- Crawlers: Mínimo de 10 minutos, depois por segundo

✅ **Data Catalog:**
- Primeiro 1 milhão de objetos: **GRATUITO**
- Objetos adicionais: $1.00 por 100.000 objetos/mês

✅ **FLEX:**
- Desconto médio: 40% (pode variar)
- Utiliza capacidade ociosa da AWS

## 📝 Notas Importantes

1. **Preços podem mudar**: A AWS pode atualizar preços periodicamente. Recomenda-se verificar a página oficial regularmente.

2. **Região sa-east-1**: Tem preço mais alto ($0.60 vs $0.44) devido aos custos de infraestrutura na região.

3. **FLEX**: O desconto pode variar dependendo da disponibilidade de capacidade ociosa. Usamos 40% como média conservadora.

4. **Última atualização**: Janeiro 2025

## 🔗 Links Úteis

- [AWS Glue Pricing](https://aws.amazon.com/glue/pricing/)
- [AWS Glue Documentation](https://docs.aws.amazon.com/glue/)
- [AWS Pricing Calculator](https://calculator.aws/)

## 🛠️ Como Atualizar Preços no Futuro

1. Acesse https://aws.amazon.com/glue/pricing/
2. Verifique os preços por região
3. Atualize o objeto `dpuHourlyRateByRegion` em `calculator.js`
4. Atualize a data de "Última atualização" nos comentários

