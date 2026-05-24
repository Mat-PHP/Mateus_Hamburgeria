# 🍔 Mateus Hamburgueria



## 🚀 Como Executar

### 1. Backend (JSON Server)
```bash
# Instale o JSON Server globalmente
npm install -g json-server

# Inicie o servidor
json-server --watch db.json --host 10.109.72.17 --port 30
```

### 2. App Flutter
```bash
# Instale as dependências
flutter pub get

# Execute o app
flutter run -d chrome
```

## 📁 Estrutura do Projeto

```
lib/
├── main.dart              # Ponto de entrada
├── models/
│   ├── burger.dart        # Modelo de Hambúrguer (POO)
│   └── user.dart          # Modelo de Usuário e Pedido
├── screens/
│   ├── login_page.dart    # Tela de Login (autenticação)
│   ├── home_page.dart     # Cardápio (listas, navegação)
│   ├── payment_page.dart  # Pagamento (CRUD completo)
│   └── orders_page.dart   # Histórico de pedidos
└── services/
    ├── api_service.dart   # Comunicação RESTful
    └── local_storage.dart # Persistência local
```

## 🔧 Funcionalidades

- **Login**: Autenticação com email/senha via API
- **Cardápio**: Lista de hambúrgueres com imagens e preços
- **Carrinho**: Adicionar/remover itens com persistência local
- **Pagamento**: Finalizar pedido com POST para API
- **Histórico**: Visualizar pedidos do servidor e local
- **CRUD Completo**: Criar, ler, atualizar e excluir pedidos

## 👨‍💻 Autor
Desenvolvido por Mateus para a disciplina PPDM - SENAI Roberto Mange.
