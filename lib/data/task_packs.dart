import '../models/task_model.dart';

class TaskPackItem {
  final String title;
  final String? description;
  final TaskCategory category;
  final TaskFrequency frequency;
  final int points;

  const TaskPackItem({
    required this.title,
    this.description,
    required this.category,
    required this.frequency,
    required this.points,
  });
}

class TaskPack {
  final String id;
  final String name;
  final String icon;
  final int colorValue;
  final List<TaskPackItem> tasks;

  const TaskPack({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorValue,
    required this.tasks,
  });
}

class TaskPacks {
  static const List<TaskPack> all = [
    // ─── COZINHA ───
    TaskPack(
      id: 'kitchen',
      name: 'Cozinha',
      icon: 'restaurant',
      colorValue: 0xFFEF4444,
      tasks: [
        TaskPackItem(
          title: 'Lavar a louça',
          description: 'Lavar pratos, copos, talheres e panelas',
          category: TaskCategory.kitchen,
          frequency: TaskFrequency.daily,
          points: 10,
        ),
        TaskPackItem(
          title: 'Limpar o fogão',
          description: 'Limpar bocas, grelhas e superfície do fogão',
          category: TaskCategory.kitchen,
          frequency: TaskFrequency.weekly,
          points: 15,
        ),
        TaskPackItem(
          title: 'Limpar a geladeira',
          description: 'Organizar e limpar prateleiras da geladeira',
          category: TaskCategory.kitchen,
          frequency: TaskFrequency.biweekly,
          points: 20,
        ),
        TaskPackItem(
          title: 'Limpar o microondas',
          description: 'Limpar por dentro e por fora',
          category: TaskCategory.kitchen,
          frequency: TaskFrequency.weekly,
          points: 10,
        ),
        TaskPackItem(
          title: 'Passar pano no chão da cozinha',
          description: 'Varrer e passar pano úmido',
          category: TaskCategory.kitchen,
          frequency: TaskFrequency.daily,
          points: 10,
        ),
        TaskPackItem(
          title: 'Limpar a pia',
          description: 'Esfregar e desinfetar a pia',
          category: TaskCategory.kitchen,
          frequency: TaskFrequency.daily,
          points: 5,
        ),
        TaskPackItem(
          title: 'Organizar despensa',
          description: 'Verificar validade e organizar alimentos',
          category: TaskCategory.organization,
          frequency: TaskFrequency.monthly,
          points: 20,
        ),
        TaskPackItem(
          title: 'Tirar o lixo da cozinha',
          description: 'Retirar e trocar o saco de lixo',
          category: TaskCategory.kitchen,
          frequency: TaskFrequency.daily,
          points: 5,
        ),
      ],
    ),

    // ─── SALA ───
    TaskPack(
      id: 'living_room',
      name: 'Sala',
      icon: 'weekend',
      colorValue: 0xFF3B82F6,
      tasks: [
        TaskPackItem(
          title: 'Aspirar/varrer a sala',
          description: 'Aspirar tapetes e varrer o chão',
          category: TaskCategory.cleaning,
          frequency: TaskFrequency.weekly,
          points: 15,
        ),
        TaskPackItem(
          title: 'Tirar o pó dos móveis',
          description: 'Passar pano nos móveis, estantes e prateleiras',
          category: TaskCategory.cleaning,
          frequency: TaskFrequency.weekly,
          points: 10,
        ),
        TaskPackItem(
          title: 'Limpar a TV e eletrônicos',
          description: 'Passar pano seco na tela e superfícies',
          category: TaskCategory.cleaning,
          frequency: TaskFrequency.weekly,
          points: 10,
        ),
        TaskPackItem(
          title: 'Organizar almofadas e mantas',
          description: 'Arrumar sofá e almofadas',
          category: TaskCategory.organization,
          frequency: TaskFrequency.daily,
          points: 5,
        ),
        TaskPackItem(
          title: 'Limpar janelas da sala',
          description: 'Limpar vidros e peitoris',
          category: TaskCategory.cleaning,
          frequency: TaskFrequency.monthly,
          points: 20,
        ),
        TaskPackItem(
          title: 'Passar pano no chão da sala',
          description: 'Passar pano úmido no piso',
          category: TaskCategory.cleaning,
          frequency: TaskFrequency.weekly,
          points: 10,
        ),
      ],
    ),

    // ─── QUARTO ───
    TaskPack(
      id: 'bedroom',
      name: 'Quarto',
      icon: 'bed',
      colorValue: 0xFF8B5CF6,
      tasks: [
        TaskPackItem(
          title: 'Arrumar a cama',
          description: 'Esticar lençol e organizar travesseiros',
          category: TaskCategory.organization,
          frequency: TaskFrequency.daily,
          points: 5,
        ),
        TaskPackItem(
          title: 'Trocar roupa de cama',
          description: 'Trocar lençóis, fronhas e edredom',
          category: TaskCategory.laundry,
          frequency: TaskFrequency.weekly,
          points: 15,
        ),
        TaskPackItem(
          title: 'Organizar guarda-roupa',
          description: 'Dobrar roupas e organizar prateleiras',
          category: TaskCategory.organization,
          frequency: TaskFrequency.monthly,
          points: 25,
        ),
        TaskPackItem(
          title: 'Aspirar/varrer o quarto',
          description: 'Limpar o chão do quarto',
          category: TaskCategory.cleaning,
          frequency: TaskFrequency.weekly,
          points: 10,
        ),
        TaskPackItem(
          title: 'Tirar o pó do quarto',
          description: 'Limpar superfícies, criado-mudo e cômodas',
          category: TaskCategory.cleaning,
          frequency: TaskFrequency.weekly,
          points: 10,
        ),
        TaskPackItem(
          title: 'Organizar mesa de estudo/trabalho',
          description: 'Arrumar papéis, livros e materiais',
          category: TaskCategory.organization,
          frequency: TaskFrequency.weekly,
          points: 10,
        ),
      ],
    ),

    // ─── BANHEIRO ───
    TaskPack(
      id: 'bathroom',
      name: 'Banheiro',
      icon: 'bathtub',
      colorValue: 0xFF06B6D4,
      tasks: [
        TaskPackItem(
          title: 'Limpar o vaso sanitário',
          description: 'Esfregar e desinfetar o vaso',
          category: TaskCategory.cleaning,
          frequency: TaskFrequency.weekly,
          points: 15,
        ),
        TaskPackItem(
          title: 'Limpar o box/banheira',
          description: 'Esfregar paredes e piso do box',
          category: TaskCategory.cleaning,
          frequency: TaskFrequency.weekly,
          points: 15,
        ),
        TaskPackItem(
          title: 'Limpar a pia do banheiro',
          description: 'Esfregar e desinfetar pia e espelho',
          category: TaskCategory.cleaning,
          frequency: TaskFrequency.weekly,
          points: 10,
        ),
        TaskPackItem(
          title: 'Trocar toalhas',
          description: 'Substituir toalhas de banho e rosto',
          category: TaskCategory.laundry,
          frequency: TaskFrequency.weekly,
          points: 5,
        ),
        TaskPackItem(
          title: 'Repor papel higiênico e sabonete',
          description: 'Verificar e repor itens do banheiro',
          category: TaskCategory.organization,
          frequency: TaskFrequency.weekly,
          points: 5,
        ),
        TaskPackItem(
          title: 'Limpar o chão do banheiro',
          description: 'Lavar e secar o piso',
          category: TaskCategory.cleaning,
          frequency: TaskFrequency.weekly,
          points: 10,
        ),
      ],
    ),

    // ─── ÁREA DE SERVIÇO ───
    TaskPack(
      id: 'laundry',
      name: 'Área de Serviço',
      icon: 'local_laundry_service',
      colorValue: 0xFFF59E0B,
      tasks: [
        TaskPackItem(
          title: 'Lavar roupas',
          description: 'Separar, lavar e colocar para secar',
          category: TaskCategory.laundry,
          frequency: TaskFrequency.weekly,
          points: 15,
        ),
        TaskPackItem(
          title: 'Passar roupas',
          description: 'Passar e dobrar roupas limpas',
          category: TaskCategory.laundry,
          frequency: TaskFrequency.weekly,
          points: 15,
        ),
        TaskPackItem(
          title: 'Recolher roupas do varal',
          description: 'Retirar roupas secas e dobrar',
          category: TaskCategory.laundry,
          frequency: TaskFrequency.daily,
          points: 10,
        ),
        TaskPackItem(
          title: 'Limpar a máquina de lavar',
          description: 'Fazer ciclo de limpeza da máquina',
          category: TaskCategory.cleaning,
          frequency: TaskFrequency.monthly,
          points: 15,
        ),
        TaskPackItem(
          title: 'Organizar produtos de limpeza',
          description: 'Verificar estoque e organizar',
          category: TaskCategory.organization,
          frequency: TaskFrequency.monthly,
          points: 10,
        ),
      ],
    ),

    // ─── JARDIM / ÁREA EXTERNA ───
    TaskPack(
      id: 'garden',
      name: 'Jardim / Área Externa',
      icon: 'yard',
      colorValue: 0xFF10B981,
      tasks: [
        TaskPackItem(
          title: 'Regar as plantas',
          description: 'Regar jardim e vasos',
          category: TaskCategory.garden,
          frequency: TaskFrequency.daily,
          points: 10,
        ),
        TaskPackItem(
          title: 'Cortar a grama',
          description: 'Aparar grama do jardim',
          category: TaskCategory.garden,
          frequency: TaskFrequency.biweekly,
          points: 25,
        ),
        TaskPackItem(
          title: 'Podar plantas',
          description: 'Podar arbustos e plantas do jardim',
          category: TaskCategory.garden,
          frequency: TaskFrequency.monthly,
          points: 20,
        ),
        TaskPackItem(
          title: 'Varrer a calçada/garagem',
          description: 'Limpar área externa',
          category: TaskCategory.cleaning,
          frequency: TaskFrequency.weekly,
          points: 15,
        ),
        TaskPackItem(
          title: 'Limpar churrasqueira',
          description: 'Limpar grelha e área da churrasqueira',
          category: TaskCategory.cleaning,
          frequency: TaskFrequency.biweekly,
          points: 15,
        ),
        TaskPackItem(
          title: 'Retirar folhas secas',
          description: 'Recolher folhas do jardim e calçada',
          category: TaskCategory.garden,
          frequency: TaskFrequency.weekly,
          points: 10,
        ),
      ],
    ),

    // ─── ESCRITÓRIO / HOME OFFICE ───
    TaskPack(
      id: 'office',
      name: 'Escritório',
      icon: 'computer',
      colorValue: 0xFF64748B,
      tasks: [
        TaskPackItem(
          title: 'Organizar a mesa',
          description: 'Arrumar papéis, canetas e materiais',
          category: TaskCategory.organization,
          frequency: TaskFrequency.daily,
          points: 5,
        ),
        TaskPackItem(
          title: 'Limpar tela do computador',
          description: 'Passar pano anti-estático na tela',
          category: TaskCategory.cleaning,
          frequency: TaskFrequency.weekly,
          points: 5,
        ),
        TaskPackItem(
          title: 'Organizar cabos e fios',
          description: 'Arrumar e agrupar cabos',
          category: TaskCategory.organization,
          frequency: TaskFrequency.monthly,
          points: 10,
        ),
        TaskPackItem(
          title: 'Limpar teclado e mouse',
          description: 'Limpar periféricos do computador',
          category: TaskCategory.cleaning,
          frequency: TaskFrequency.weekly,
          points: 5,
        ),
        TaskPackItem(
          title: 'Organizar documentos e arquivos',
          description: 'Arquivar papéis e organizar gavetas',
          category: TaskCategory.organization,
          frequency: TaskFrequency.monthly,
          points: 15,
        ),
      ],
    ),

    // ─── PETS ───
    TaskPack(
      id: 'pets',
      name: 'Pets',
      icon: 'pets',
      colorValue: 0xFFEC4899,
      tasks: [
        TaskPackItem(
          title: 'Alimentar os pets',
          description: 'Colocar ração e água fresca',
          category: TaskCategory.pets,
          frequency: TaskFrequency.daily,
          points: 10,
        ),
        TaskPackItem(
          title: 'Passear com o cachorro',
          description: 'Levar para passear e fazer necessidades',
          category: TaskCategory.pets,
          frequency: TaskFrequency.daily,
          points: 15,
        ),
        TaskPackItem(
          title: 'Limpar a caixa de areia',
          description: 'Trocar areia e limpar a caixa do gato',
          category: TaskCategory.pets,
          frequency: TaskFrequency.daily,
          points: 10,
        ),
        TaskPackItem(
          title: 'Dar banho no pet',
          description: 'Banho e escovação',
          category: TaskCategory.pets,
          frequency: TaskFrequency.biweekly,
          points: 20,
        ),
        TaskPackItem(
          title: 'Limpar área do pet',
          description: 'Lavar comedouros e limpar caminha',
          category: TaskCategory.pets,
          frequency: TaskFrequency.weekly,
          points: 10,
        ),
      ],
    ),
  ];
}
