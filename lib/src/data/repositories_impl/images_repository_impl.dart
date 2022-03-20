import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart';
import 'package:my_puzzle/src/domain/models/puzzle_image.dart';
import 'package:my_puzzle/src/domain/repositories/images_repository.dart';

const puzzleOptions = <PuzzleImage>[
  PuzzleImage(
    name: 'Numeric',
    assetPath: 'assets/images/numeric-puzzle.png',
    soundPath: '',
  ),
  PuzzleImage(
    name: 'Cute Nezuko',
    assetPath: 'assets/fav_images/cute_nezuko.png',
    soundPath: 'assets/sounds/nezuko_sound.mp3',
  ),
  PuzzleImage(
    name: 'Funny Nezuko',
    assetPath: 'assets/fav_images/funny_nezuko.png',
    soundPath: 'assets/sounds/nezuko_sound.mp3',
  ),
  PuzzleImage(
    name: 'Child of Light',
    assetPath: 'assets/fav_images/child_of_light.png',
    soundPath: '',
  ),
  PuzzleImage(
    name: 'Fez',
    assetPath: 'assets/fav_images/fez.png',
    soundPath: 'assets/sounds/fez_cube.mp3',
  ),
  PuzzleImage(
    name: 'FMAB Edward',
    assetPath: 'assets/fav_images/fmab_edward.png',
    soundPath: '',
  ),
  PuzzleImage(
    name: 'FMAB Symbol',
    assetPath: 'assets/fav_images/fmab_symbol.png',
    soundPath: '',
  ),
  PuzzleImage(
    name: 'FMAB Shocked Face',
    assetPath: 'assets/fav_images/shocked_face.png',
    soundPath: 'assets/sounds/short_complex_2.mp3',
  ),
  PuzzleImage(
    name: 'FMAB Smug Face',
    assetPath: 'assets/fav_images/smug_face.png',
    soundPath: 'assets/sounds/short_complex_1.mp3',
  ),
  PuzzleImage(
    name: 'Skyrim',
    assetPath: 'assets/fav_images/skyrim_symbol.png',
    soundPath: 'assets/sounds/violated_law.mp3',
  ),
  PuzzleImage(
    name: 'Professor Layton Top Hat',
    assetPath: 'assets/fav_images/professor_layton_tophat.png',
    soundPath: 'assets/sounds/puzzle_battle.mp4',
  ),
  PuzzleImage(
    name: 'Professor Layton',
    assetPath: 'assets/fav_images/professor_layton.jpeg',
    soundPath: 'assets/sounds/puzzle_battle.mp4',
  ),
  PuzzleImage(
    name: 'Porygon',
    assetPath: 'assets/fav_images/porygon.png',
    soundPath: 'assets/sounds/porygon_anime_cry.mp3',
  ),
  PuzzleImage(
    name: 'Undertale Sans',
    assetPath: 'assets/fav_images/undertale_sans.png',
    soundPath: 'assets/sounds/undertale_sans.mp4',
  ),
  PuzzleImage(
    name: 'Undertale Flowey',
    assetPath: 'assets/fav_images/undertale_flowey.png',
    soundPath: 'assets/sounds/undertale_flowey.mp4',
  ),
  PuzzleImage(
    name: 'Undertale Sans',
    assetPath: 'assets/fav_images/undertale_muffet.png',
    soundPath: 'assets/sounds/undertale_muffet.mp4',
  ),
  PuzzleImage(
    name: 'Undertale Sans',
    assetPath: 'assets/fav_images/undertale_dog.png',
    soundPath: 'assets/sounds/undertale_dog.mp4',
  ),
];

Future<Image> decodeAsset(ByteData bytes) async {
  return decodeImage(
    bytes.buffer.asUint8List(),
  )!;
}

class SPlitData {
  final Image image;
  final int crossAxisCount;

  SPlitData(this.image, this.crossAxisCount);
}

Future<List<Uint8List>> splitImage(SPlitData data) {
  final image = data.image;
  final crossAxisCount = data.crossAxisCount;
  final int length = (image.width / crossAxisCount).round();
  List<Uint8List> pieceList = [];

  for (int y = 0; y < crossAxisCount; y++) {
    for (int x = 0; x < crossAxisCount; x++) {
      pieceList.add(
        Uint8List.fromList(
          encodePng(
            copyCrop(
              image,
              x * length,
              y * length,
              length,
              length,
            ),
          ),
        ),
      );
    }
  }
  return Future.value(pieceList);
}

class ImagesRepositoryImpl implements ImagesRepository {
  Map<String, Image> cache = {};

  @override
  Future<List<Uint8List>> split(String asset, int crossAxisCount) async {
    late Image image;
    if (cache.containsKey(asset)) {
      image = cache[asset]!;
    } else {
      final bytes = await rootBundle.load(asset);

      /// use compute because theimage package is a pure dart package
      /// so to avoid bad ui performance we do this task in a different
      /// isolate
      image = await compute(decodeAsset, bytes);

      final width = math.min(image.width, image.height);

      /// convert to square
      image = copyResizeCropSquare(image, width);
      cache[asset] = image;
    }

    final pieces = await compute(
      splitImage,
      SPlitData(image, crossAxisCount),
    );

    return pieces;
  }
}
