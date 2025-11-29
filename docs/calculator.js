// Configurações de preços AWS Glue (atualizado 2024-2025)
// Fonte: https://aws.amazon.com/glue/pricing/
const PRICING = {
    // Preço por DPU-Hora em USD por região
    // Valores baseados na página oficial de pricing da AWS
    // Última atualização: Janeiro 2025
    dpuHourlyRateByRegion: {
        'us-east-1': 0.44,      // N. Virginia
        'us-east-2': 0.44,      // Ohio
        'us-west-1': 0.44,      // N. California
        'us-west-2': 0.44,      // Oregon
        'sa-east-1': 0.60,      // São Paulo (preço mais alto)
        'eu-west-1': 0.44,      // Ireland
        'eu-central-1': 0.44,   // Frankfurt
        'ap-southeast-1': 0.44   // Singapore
    },
    
    // Worker Types e seus DPUs
    // Fonte: Documentação oficial AWS Glue
    workerTypes: {
        'G.025X': 0.25,  // 0.25 DPU - Menor custo
        'G.1X': 1,       // 1 DPU - Recomendado para maioria dos casos
        'G.2X': 2,       // 2 DPUs
        'G.4X': 4,       // 4 DPUs
        'G.8X': 8        // 8 DPUs - Máxima performance
    },
    
    // Desconto para FLEX
    // FLEX oferece desconto significativo usando capacidade ociosa
    // Desconto pode variar, usando 40% como média conservadora
    flexDiscount: 0.40,
    
    // Mínimo de cobrança: 1 minuto para jobs ETL
    // Fonte: AWS Glue pricing - billed per second with 1-minute minimum
    minBillingMinutes: 1,
    
    // Data Catalog: primeiro 1 milhão de objetos é gratuito
    // Depois: $1.00 por 100.000 objetos adicionais por mês
    // Fonte: AWS Glue Data Catalog pricing
    dataCatalogFreeTier: 1000000,
    dataCatalogPricePer100k: 1.00,
    
    // Crawler: mesmo preço que ETL jobs, mas mínimo de 10 minutos
    // Fonte: AWS Glue Crawler pricing
    crawlerMinBillingMinutes: 10,
    
    // AWS Free Tier (12 meses)
    // O AWS Free Tier oferece recursos gratuitos por 12 meses para novos clientes
    // Nota: O AWS Glue não tem um free tier específico, mas outros serviços relacionados podem ter
    // Para fins de cálculo, consideramos que o free tier pode reduzir custos iniciais
    // Fonte: https://aws.amazon.com/free/
    freeTier: {
        // Nota: AWS Glue não oferece free tier específico, mas alguns custos podem ser reduzidos
        // em contas novas através de créditos promocionais ou outros benefícios
        // Este campo é mantido para flexibilidade futura
        enabled: false
    }
};

// Função para obter o preço por DPU-Hora baseado na região
function getDpuHourlyRate(region) {
    return PRICING.dpuHourlyRateByRegion[region] || PRICING.dpuHourlyRateByRegion['us-east-1'];
}

// Função para formatar valores monetários
function formatCurrency(value) {
    return new Intl.NumberFormat('pt-BR', {
        style: 'currency',
        currency: 'USD',
        minimumFractionDigits: 4,
        maximumFractionDigits: 4
    }).format(value);
}

// Função para formatar valores monetários simplificados
function formatCurrencySimple(value) {
    return new Intl.NumberFormat('pt-BR', {
        style: 'currency',
        currency: 'USD',
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
    }).format(value);
}

// Calcular custo do job ETL
function calculateJobCost(executionTime, workerType, numberOfWorkers, executionType, awsRegion) {
    const dpuPerWorker = PRICING.workerTypes[workerType];
    const totalDPUs = dpuPerWorker * numberOfWorkers;
    
    // Obter preço por DPU-Hora baseado na região
    const dpuHourlyRate = getDpuHourlyRate(awsRegion);
    
    // Converter minutos para horas
    const executionHours = executionTime / 60;
    
    // Aplicar mínimo de 1 minuto
    const billedMinutes = Math.max(executionTime, PRICING.minBillingMinutes);
    const billedHours = billedMinutes / 60;
    
    // Calcular custo base
    let cost = totalDPUs * billedHours * dpuHourlyRate;
    
    // Aplicar desconto FLEX se aplicável
    if (executionType === 'flex') {
        cost = cost * (1 - PRICING.flexDiscount);
    }
    
    return {
        cost: cost,
        totalDPUs: totalDPUs,
        billedMinutes: billedMinutes,
        executionHours: executionHours,
        dpuPerWorker: dpuPerWorker,
        dpuHourlyRate: dpuHourlyRate
    };
}

// Calcular custo do crawler
function calculateCrawlerCost(executionTime, workerType, numberOfWorkers, executionType, awsRegion) {
    if (executionTime <= 0) {
        return {
            cost: 0,
            totalDPUs: 0,
            billedMinutes: 0
        };
    }
    
    const dpuPerWorker = PRICING.workerTypes[workerType];
    const totalDPUs = dpuPerWorker * numberOfWorkers;
    
    // Obter preço por DPU-Hora baseado na região
    const dpuHourlyRate = getDpuHourlyRate(awsRegion);
    
    // Crawler tem mínimo de 10 minutos
    const billedMinutes = Math.max(executionTime, PRICING.crawlerMinBillingMinutes);
    const billedHours = billedMinutes / 60;
    
    // Calcular custo base
    let cost = totalDPUs * billedHours * dpuHourlyRate;
    
    // Aplicar desconto FLEX se aplicável
    if (executionType === 'flex') {
        cost = cost * (1 - PRICING.flexDiscount);
    }
    
    return {
        cost: cost,
        totalDPUs: totalDPUs,
        billedMinutes: billedMinutes
    };
}

// Calcular custo do Data Catalog
function calculateDataCatalogCost(objectsInMillions) {
    if (objectsInMillions <= 0) {
        return {
            cost: 0,
            objects: 0,
            billableObjects: 0
        };
    }
    
    const totalObjects = objectsInMillions * 1000000;
    const billableObjects = Math.max(0, totalObjects - PRICING.dataCatalogFreeTier);
    
    if (billableObjects <= 0) {
        return {
            cost: 0,
            objects: totalObjects,
            billableObjects: 0
        };
    }
    
    // Calcular custo: $1.00 por 100.000 objetos adicionais
    const cost = (billableObjects / 100000) * PRICING.dataCatalogPricePer100k;
    
    return {
        cost: cost,
        objects: totalObjects,
        billableObjects: billableObjects
    };
}

// Função principal de cálculo
function calculateTotalCost(formData) {
    const executionTime = parseFloat(formData.executionTime) || 0;
    const workerType = formData.workerType;
    const numberOfWorkers = parseInt(formData.numberOfWorkers) || 1;
    const executionType = formData.executionType;
    const awsRegion = formData.awsRegion || 'us-east-1';
    const dataCatalogObjects = parseFloat(formData.dataCatalogObjects) || 0;
    const crawlerExecutionTime = parseFloat(formData.crawlerExecutionTime) || 0;
    const hasFreeTier = formData.hasFreeTier === 'true' || formData.hasFreeTier === true;
    
    // Calcular custos (passando a região)
    const jobCost = calculateJobCost(executionTime, workerType, numberOfWorkers, executionType, awsRegion);
    const crawlerCost = calculateCrawlerCost(crawlerExecutionTime, workerType, numberOfWorkers, executionType, awsRegion);
    const catalogCost = calculateDataCatalogCost(dataCatalogObjects);
    
    // Aplicar free tier se aplicável
    // Nota: AWS Glue não tem free tier específico, mas contas novas podem ter créditos promocionais
    // Por enquanto, mantemos a estrutura para futuras implementações
    let freeTierSavings = 0;
    let freeTierNote = '';
    
    if (hasFreeTier) {
        // AWS Free Tier geralmente oferece créditos ou recursos gratuitos
        // Para AWS Glue especificamente, não há free tier, mas podemos considerar
        // que contas novas podem ter créditos promocionais que reduzem custos
        freeTierNote = 'Nota: AWS Glue não possui free tier específico. Contas novas podem ter créditos promocionais da AWS que reduzem custos.';
    }
    
    // Calcular total
    const totalCost = Math.max(0, jobCost.cost + crawlerCost.cost + catalogCost.cost - freeTierSavings);
    
    return {
        job: jobCost,
        crawler: crawlerCost,
        catalog: catalogCost,
        total: totalCost,
        region: awsRegion,
        hasFreeTier: hasFreeTier,
        freeTierSavings: freeTierSavings,
        freeTierNote: freeTierNote
    };
}

// Função para exibir resultados
function displayResults(results) {
    const resultsDiv = document.getElementById('results');
    resultsDiv.classList.remove('hidden');
    
    // Job Cost
    document.getElementById('jobCost').textContent = formatCurrencySimple(results.job.cost);
    const regionName = document.getElementById('awsRegion').selectedOptions[0].text;
    const jobDetails = `
        <div>Região: <strong>${regionName}</strong></div>
        <div>Preço por DPU-Hora: <strong>$${results.job.dpuHourlyRate.toFixed(2)}</strong></div>
        <div>Total de DPUs: <strong>${results.job.totalDPUs}</strong> (${results.job.dpuPerWorker} DPU × ${document.getElementById('numberOfWorkers').value} workers)</div>
        <div>Tempo de execução: <strong>${parseFloat(document.getElementById('executionTime').value)} minutos</strong></div>
        <div>Tempo faturado: <strong>${results.job.billedMinutes} minutos</strong> (mínimo de 1 minuto)</div>
        ${document.getElementById('executionType').value === 'flex' ? '<div>Desconto FLEX aplicado: <strong>40%</strong></div>' : ''}
    `;
    document.getElementById('jobDetails').innerHTML = jobDetails;
    
    // Crawler Cost
    if (results.crawler.cost > 0) {
        document.getElementById('crawlerCard').style.display = 'block';
        document.getElementById('crawlerCost').textContent = formatCurrencySimple(results.crawler.cost);
        const crawlerDetails = `
            <div>Total de DPUs: <strong>${results.crawler.totalDPUs}</strong></div>
            <div>Tempo faturado: <strong>${results.crawler.billedMinutes} minutos</strong> (mínimo de 10 minutos para crawlers)</div>
        `;
        document.getElementById('crawlerDetails').innerHTML = crawlerDetails;
    } else {
        document.getElementById('crawlerCard').style.display = 'none';
    }
    
    // Catalog Cost
    if (results.catalog.cost > 0) {
        document.getElementById('catalogCard').style.display = 'block';
        document.getElementById('catalogCost').textContent = formatCurrencySimple(results.catalog.cost);
        const catalogDetails = `
            <div>Total de objetos: <strong>${results.catalog.objects.toLocaleString('pt-BR')}</strong></div>
            <div>Objetos faturados: <strong>${results.catalog.billableObjects.toLocaleString('pt-BR')}</strong> (após 1 milhão gratuito)</div>
            <div>Preço: <strong>$1.00 por 100.000 objetos/mês</strong></div>
        `;
        document.getElementById('catalogDetails').innerHTML = catalogDetails;
    } else if (results.catalog.objects > 0) {
        document.getElementById('catalogCard').style.display = 'block';
        document.getElementById('catalogCost').textContent = formatCurrencySimple(0);
        document.getElementById('catalogDetails').innerHTML = `
            <div>Total de objetos: <strong>${results.catalog.objects.toLocaleString('pt-BR')}</strong></div>
            <div>✅ Dentro do tier gratuito (primeiro 1 milhão é gratuito)</div>
        `;
    } else {
        document.getElementById('catalogCard').style.display = 'none';
    }
    
    // Total Cost
    document.getElementById('totalCost').textContent = formatCurrencySimple(results.total);
    
    // Free Tier Note
    if (results.hasFreeTier && results.freeTierNote) {
        const freeTierNoteDiv = document.createElement('div');
        freeTierNoteDiv.className = 'result-card info-card';
        freeTierNoteDiv.style.marginTop = '15px';
        freeTierNoteDiv.innerHTML = `<p style="margin: 0; color: #78350f;">ℹ️ ${results.freeTierNote}</p>`;
        
        // Remover nota anterior se existir
        const existingNote = document.getElementById('freeTierNote');
        if (existingNote) {
            existingNote.remove();
        }
        
        freeTierNoteDiv.id = 'freeTierNote';
        resultsDiv.appendChild(freeTierNoteDiv);
    } else {
        const existingNote = document.getElementById('freeTierNote');
        if (existingNote) {
            existingNote.remove();
        }
    }
    
    // Scroll para resultados
    resultsDiv.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
}

// Event Listener para o formulário
document.getElementById('costCalculator').addEventListener('submit', function(e) {
    e.preventDefault();
    
    const formData = {
        executionTime: document.getElementById('executionTime').value,
        workerType: document.getElementById('workerType').value,
        numberOfWorkers: document.getElementById('numberOfWorkers').value,
        executionType: document.getElementById('executionType').value,
        awsRegion: document.getElementById('awsRegion').value,
        dataCatalogObjects: document.getElementById('dataCatalogObjects').value,
        crawlerExecutionTime: document.getElementById('crawlerExecutionTime').value,
        hasFreeTier: document.getElementById('hasFreeTier').checked
    };
    
    const results = calculateTotalCost(formData);
    displayResults(results);
});

// Validação em tempo real
document.getElementById('executionTime').addEventListener('input', function() {
    if (this.value < 0.1) {
        this.setCustomValidity('O tempo mínimo é 0.1 minutos');
    } else {
        this.setCustomValidity('');
    }
});

document.getElementById('numberOfWorkers').addEventListener('input', function() {
    if (this.value < 1) {
        this.setCustomValidity('O número mínimo de workers é 1');
    } else {
        this.setCustomValidity('');
    }
});

