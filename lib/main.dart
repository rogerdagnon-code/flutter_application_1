import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
} //inicialização e estrutura principal

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),    
        ),
        home: MyHomePage(),
      ),
    );
  }
} //configurações padroes do app

//Logica de negocios
class MyAppState extends ChangeNotifier {
  var current = PalavraPair.random(); //armazena a palavra aleatoria atual
  var favorites = <PalavraPair> []; // lista de amazena as palavras quando favoritadas

  void getNext(){ // gera uma nova palavra aleatoria
    current = PalavraPair.random();
    notifyListeners();
  }

  void toggleFavorite() { // adiciona a palavra atual aos favoritos
    if (favorites.contains(current)){
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

// Tela principal e navegação - StatefulWidget guarda o estado local de qual aba está selecionada
class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
    case 0:
      page = GeneratorPage();
      break;
    case 1:
      page = FavoritesPage();
      break;
    default:
      throw UnimplementedError('Nenhum widget para o índice $selectedIndex');
  }
    
    return LayoutBuilder( //analisa o espaço disponivel na tela, 
      builder: (context, constraints) {
        return Scaffold(
          body: Row( //divide as duas colunas
            children: [
              SafeArea(
                child: NavigationRail( //se a altura for maior ou igual a 600p, o menu lateral se expande automaticamente, caso contrario mostra somente os icones
                  extended: constraints.maxHeight >= 600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Início'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favoritos'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
        
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

// Pag do gerador - exibe o bigcard e os 2 botoes
class GeneratorPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Gostei'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Próximo'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Cartao personalizado
class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final PalavraPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.primeira} ${pair.segunda}",
          ),
      ),
    );
  }
}

//Pag de favoritos - verifica a lista se vazia, mostra um mensagem, se ouver itens retorna o listview gerando um listTile
class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('Nenhum favorito adicionado.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('Você tem '
              '${appState.favorites.length} favoritos:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}

// --- CLASSE AUXILIAR EM PORTUGUÊS DEFINITIVA (SEM DEPENDER DO FAKER EM INGLÊS) ---
class PalavraPair {
  final String primeira;
  final String segunda;

  PalavraPair(this.primeira, this.segunda);

// ADICIONADO ESPAÇO: Agora adiciona um espaço entre as duas palavras minúsculas
  String get asLowerCase => '${primeira.toLowerCase()} ${segunda.toLowerCase()}';

  // ADICIONADO ESPAÇO: Também adiciona espaço no formato PascalCase se usar no futuro
  String get asPascalCase {
    if (primeira.isEmpty || segunda.isEmpty) return '';
    final p1 = '${primeira[0].toUpperCase()}${primeira.substring(1)}';
    final p2 = '${segunda[0].toUpperCase()}${segunda.substring(1)}';
    return '$p1 $p2';
  }

  // Gera um par de palavras aleatórias usando um banco de dados nativo em PT-BR
  static PalavraPair random() {
    final random = Random();
    
    // Lista diversificada de palavras e ideias em português do Brasil
    final substantivos = [
      'casa', 'sol', 'lua', 'mar', 'rio', 'vento', 'gato', 'livro', 'cafe', 
      'fogo', 'terra', 'arte', 'som', 'luz', 'mente', 'vida', 'codigo', 'pao',
      'tempo', 'jogo', 'app', 'tela', 'nuvem', 'chave', 'porto', 'mastro',
      'lobo', 'norte', 'sul', 'astro', 'plano', 'ponto', 'foco', 'sal'
    ];
    final adjetivos = [
      'azul', 'verde', 'forte', 'doce', 'novo', 'belo', 'livre', 'sabio', 
      'raro', 'vivo', 'claro', 'bravo', 'agil', 'zen', 'tech', 'pop', 'bom',
      'util', 'fiel', 'grato', 'leve', 'quente', 'frio', 'alto', 'lindo',
      'reais', 'macro', 'micro', 'doce', 'suave', 'pleno', 'veloz', 'caro'
    ];

    return PalavraPair(
      substantivos[random.nextInt(substantivos.length)],
      adjetivos[random.nextInt(adjetivos.length)],
    );
  }
}