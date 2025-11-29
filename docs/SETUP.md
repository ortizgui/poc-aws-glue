# 🚀 Guia Rápido - Configurar GitHub Pages

## Passo a Passo

### 1. Fazer Commit e Push dos Arquivos

```bash
git add docs/
git commit -m "Adiciona calculadora de custos AWS Glue"
git push origin main
```

### 2. Ativar GitHub Pages

1. Acesse seu repositório no GitHub
2. Vá em **Settings** (Configurações)
3. No menu lateral, clique em **Pages**
4. Em **Source**, selecione:
   - Branch: `main`
   - Folder: `/docs`
5. Clique em **Save**

### 3. Aguardar Publicação

- Pode levar de 1 a 5 minutos para a página ficar disponível
- Você verá uma mensagem verde indicando que está publicado

### 4. Acessar a Calculadora

A URL será:
```
https://SEU-USUARIO.github.io/poc-glue-tests/
```

Substitua `SEU-USUARIO` pelo seu nome de usuário do GitHub.

## ✅ Verificação

Após configurar, você pode verificar se está funcionando:

1. Acesse a URL do GitHub Pages
2. Você deve ver a calculadora de custos
3. Preencha os campos e clique em "Calcular Custo"
4. Os resultados devem aparecer abaixo

## 🔧 Troubleshooting

### Página não aparece
- Aguarde alguns minutos (pode levar até 10 minutos na primeira vez)
- Verifique se a branch `main` está selecionada
- Verifique se a pasta `/docs` está selecionada
- Confirme que os arquivos estão na pasta `docs/`

### Erro 404
- Verifique se o arquivo `index.html` existe na pasta `docs/`
- Verifique se o arquivo `.nojekyll` existe na pasta `docs/`
- Tente acessar diretamente: `https://SEU-USUARIO.github.io/poc-glue-tests/index.html`

### Estilos não aparecem
- Verifique se o arquivo `styles.css` está na pasta `docs/`
- Verifique se os caminhos no HTML estão corretos
- Limpe o cache do navegador (Ctrl+F5 ou Cmd+Shift+R)

## 📝 Notas

- O GitHub Pages é gratuito para repositórios públicos
- Para repositórios privados, é necessário GitHub Pro
- As atualizações são automáticas quando você faz push para a branch `main`

