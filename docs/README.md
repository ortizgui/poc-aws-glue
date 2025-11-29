# Calculadora de Custos AWS Glue

Esta é a calculadora de custos para estimar o valor de execução de jobs AWS Glue, disponível via GitHub Pages.

## 📋 Sobre

A calculadora permite estimar os custos de execução de jobs AWS Glue considerando:
- Tempo de execução
- Tipo e quantidade de workers
- Tipo de execução (Standard ou FLEX)
- Região AWS
- Custos adicionais (Data Catalog, Crawlers)

## 🚀 Como Publicar no GitHub Pages

1. **Ativar GitHub Pages**:
   - Vá em `Settings` → `Pages` no seu repositório
   - Em `Source`, selecione `Deploy from a branch`
   - Escolha a branch `main` e a pasta `/docs`
   - Clique em `Save`

2. **Acessar**:
   - A URL será: `https://ortizgui.github.io/poc-glue-tests/`
   - Pode levar alguns minutos para ficar disponível

## 📁 Arquivos

- `index.html` - Interface principal da calculadora
- `styles.css` - Estilos e design responsivo
- `calculator.js` - Lógica de cálculo de custos
- `.nojekyll` - Arquivo necessário para GitHub Pages processar corretamente

## 🔧 Personalização

Para personalizar a calculadora:

1. **Preços**: Edite as constantes em `calculator.js` na seção `PRICING`
2. **Cores**: Modifique as variáveis CSS em `styles.css` na seção `:root`
3. **Texto**: Edite o conteúdo em `index.html`

## 📊 Fórmulas de Cálculo

### Job ETL
```
Custo = (DPUs por Worker × Número de Workers × Tempo Faturado em Horas × Preço por DPU-Hora)
- Standard: $0.44 por DPU-hora (varia por região)
- FLEX: $0.29 por DPU-hora (fixo, independente da região)
Tempo Mínimo Faturado: 1 minuto
```

### Crawler
```
Custo = (DPUs por Worker × Número de Workers × Tempo Faturado em Horas × $0.44)
Tempo Mínimo Faturado: 10 minutos
```

### Data Catalog
```
Custo = ((Total de Objetos - 1.000.000) / 100.000) × $1.00
Primeiro 1 milhão de objetos é gratuito
```

## 📝 Notas

- Os preços são baseados em informações públicas da AWS (2024-2025)
- Valores podem variar por região
- FLEX pode ter maior latência de inicialização
- Faturamento é por segundo após o primeiro minuto

## 🔗 Documentação Oficial de Preços

Para consultar os preços oficiais e mais atualizados do AWS Glue, consulte a documentação oficial da AWS:

- **[AWS Glue Pricing - Página Oficial](https://aws.amazon.com/glue/pricing/)**

Esta página contém:
- Preços atualizados por região
- Detalhes sobre tipos de workers e DPUs
- Informações sobre free tier e créditos promocionais
- Políticas de faturamento e mínimos
- Preços de serviços relacionados (Data Catalog, Crawlers, etc.)

**Importante:** Os valores utilizados nesta calculadora são baseados nesta documentação oficial. Recomendamos verificar periodicamente a página oficial para garantir que os valores estão atualizados.

