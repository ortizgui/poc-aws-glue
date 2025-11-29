# ✅ Correção de Preços - Atualização Janeiro 2025

## 🔍 Verificação Realizada

Comparação realizada com a página oficial da AWS: [https://aws.amazon.com/glue/pricing/](https://aws.amazon.com/glue/pricing/)

## ✅ Valores Confirmados como Corretos

### 1. ETL Jobs e Crawlers
- **Standard**: $0.44 por DPU-hora ✅
- **Faturamento**: Por segundo, com mínimo de 1 minuto para jobs ETL ✅
- **Crawlers**: Mínimo de 10 minutos ✅

### 2. Data Catalog
- **Primeiro 1 milhão de objetos**: Gratuito ✅
- **Objetos adicionais**: $1.00 por 100.000 objetos/mês ✅

### 3. Worker Types
- G.025X = 0.25 DPU ✅
- G.1X = 1 DPU ✅
- G.2X = 2 DPUs ✅
- G.4X = 4 DPUs ✅
- G.8X = 8 DPUs ✅

## 🔧 Correção Realizada

### Preço FLEX

**❌ Valor Anterior (Incorreto):**
- Desconto de 40% sobre o preço Standard
- Cálculo: $0.44 × 0.6 = $0.264 por DPU-hora

**✅ Valor Corrigido (Conforme AWS):**
- **Preço fixo: $0.29 por DPU-hora**
- Fonte: Exemplo oficial da AWS: "6 DPUs * 1/3 hour * $0.29 = $0.58"
- Economia real: ~34% em relação ao Standard ($0.44)

**Mudanças Implementadas:**
1. Substituído `flexDiscount: 0.40` por `flexDpuHourlyRate: 0.29`
2. Atualizado cálculo para usar preço fixo em vez de desconto percentual
3. FLEX agora usa $0.29 independente da região
4. Atualizada interface para mostrar preço correto
5. Atualizados documentos (README.md, PRICING_UPDATE.md)

## 📊 Comparação de Preços

| Tipo | Preço por DPU-Hora | Observação |
|------|-------------------|------------|
| Standard (us-east-1) | $0.44 | Maioria das regiões |
| Standard (sa-east-1) | $0.60 | São Paulo - preço mais alto |
| **FLEX** | **$0.29** | **Fixo, todas as regiões** |

## 📝 Notas Importantes

1. **FLEX tem preço fixo**: $0.29 por DPU-hora, independente da região
2. **Standard varia por região**: sa-east-1 tem preço mais alto ($0.60)
3. **Fonte oficial**: Todos os valores baseados em [AWS Glue Pricing](https://aws.amazon.com/glue/pricing/)

## 🔗 Referências

- [AWS Glue Pricing - Página Oficial](https://aws.amazon.com/glue/pricing/)
- Exemplo FLEX: "Alternatively, you can use Flex, for which you will be charged 6 DPUs * 1/3 hour * $0.29, which equals $0.58"

