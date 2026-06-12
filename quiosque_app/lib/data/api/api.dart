/// Ponto único de importação da camada de API "Por do Sol".
///
/// `import 'package:quiosque_app/data/api/api.dart';` dá acesso ao [ApiClient],
/// a todos os módulos de endpoint (`AuthApi`, `QuiosqueApi`, ...) e aos modelos
/// de request/response.
library;

export 'api_client.dart';
export 'api_config.dart';
export 'api_exception.dart';
export 'auth_api.dart';
export 'quiosque_api.dart';
export 'categoria_api.dart';
export 'item_api.dart';
export 'acompanhamento_api.dart';
export 'funcionario_api.dart';
export 'pedido_api.dart';
export 'models/cardapio_models.dart';
export 'models/quiosque_models.dart';
export 'models/funcionario_models.dart';
export 'models/pedido_models.dart';
