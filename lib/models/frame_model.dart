import 'package:flutter/material.dart';

enum FrameOverlayType {
  none,
  brat,
  polaroid,
  vhs,
  digicam,
  musicPlayer,
  filmstrip,
  stamp,
  retroWindow,
  cdCase,
  dateStamp,
  hazard,
  cinematic,
  minimal,
}

enum FramePhotoLayout {
  single,      // 1 photo (standard)
  split2H,     // 2 photos side by side
  split2V,     // 2 photos stacked vertically
  polaroidDuo, // 2 polaroid cards side-by-side
  triptych3,   // 3 photos side by side
  filmstrip3,  // 3 photos in vertical filmstrip
  grid4,       // 4 photos 2x2 collage
}

class FrameTemplate {
  final int id;
  final String name;
  final String category;
  final Color frameBgColor;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final EdgeInsets padding;
  final double aspectRatio;
  final String caption;
  final String captionFont;
  final Color captionColor;
  final double captionSize;
  final Alignment captionAlignment;
  final FrameOverlayType overlayType;
  final bool hasFilmGrain;
  final bool hasShadow;
  final FramePhotoLayout photoLayout;
  final int maxPhotos;

  const FrameTemplate({
    required this.id,
    required this.name,
    required this.category,
    required this.frameBgColor,
    required this.borderColor,
    this.borderWidth = 0.0,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.all(12.0),
    this.aspectRatio = 1.0,
    this.caption = '',
    this.captionFont = 'Arial',
    this.captionColor = Colors.black,
    this.captionSize = 14.0,
    this.captionAlignment = Alignment.bottomCenter,
    this.overlayType = FrameOverlayType.none,
    this.hasFilmGrain = false,
    this.hasShadow = true,
    this.photoLayout = FramePhotoLayout.single,
    this.maxPhotos = 1,
  });

  FrameTemplate copyWith({
    int? id,
    String? name,
    String? category,
    Color? frameBgColor,
    Color? borderColor,
    double? borderWidth,
    double? borderRadius,
    EdgeInsets? padding,
    double? aspectRatio,
    String? caption,
    String? captionFont,
    Color? captionColor,
    double? captionSize,
    Alignment? captionAlignment,
    FrameOverlayType? overlayType,
    bool? hasFilmGrain,
    bool? hasShadow,
    FramePhotoLayout? photoLayout,
    int? maxPhotos,
  }) {
    return FrameTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      frameBgColor: frameBgColor ?? this.frameBgColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      caption: caption ?? this.caption,
      captionFont: captionFont ?? this.captionFont,
      captionColor: captionColor ?? this.captionColor,
      captionSize: captionSize ?? this.captionSize,
      captionAlignment: captionAlignment ?? this.captionAlignment,
      overlayType: overlayType ?? this.overlayType,
      hasFilmGrain: hasFilmGrain ?? this.hasFilmGrain,
      hasShadow: hasShadow ?? this.hasShadow,
      photoLayout: photoLayout ?? this.photoLayout,
      maxPhotos: maxPhotos ?? this.maxPhotos,
    );
  }
}

FrameTemplate _f({
  required int id,
  required String name,
  required String category,
  required Color bg,
  required Color border,
  double borderWidth = 0.0,
  double borderRadius = 12.0,
  EdgeInsets padding = const EdgeInsets.all(12.0),
  double aspectRatio = 1.0,
  String caption = '',
  String captionFont = 'Arial',
  Color captionColor = Colors.black,
  double captionSize = 14.0,
  Alignment captionAlignment = Alignment.bottomCenter,
  FrameOverlayType overlayType = FrameOverlayType.none,
  bool hasFilmGrain = false,
  bool hasShadow = true,
  FramePhotoLayout photoLayout = FramePhotoLayout.single,
  int maxPhotos = 1,
}) {
  return FrameTemplate(
    id: id,
    name: name,
    category: category,
    frameBgColor: bg,
    borderColor: border,
    borderWidth: borderWidth,
    borderRadius: borderRadius,
    padding: padding,
    aspectRatio: aspectRatio,
    caption: caption,
    captionFont: captionFont,
    captionColor: captionColor,
    captionSize: captionSize,
    captionAlignment: captionAlignment,
    overlayType: overlayType,
    hasFilmGrain: hasFilmGrain,
    hasShadow: hasShadow,
    photoLayout: photoLayout,
    maxPhotos: maxPhotos,
  );
}

List<FrameTemplate> _generate500Catalog() {
  final List<FrameTemplate> list = [];

  // CATEGORY 1: 🍏 Brat & Album (1 to 50)
  const cat1 = '🍏 Brat & Album';
  final bratNames = [
    'Brat Classic Lime', 'Brat Deluxe White', '365 Party Girl', 'Von Dutch Speed', 'Club Classics',
    'Everything is Romantic', 'Sympathy is a Knife', 'Talk Talk Whisper', 'Girl So Confusing', 'Apple Core',
    'Rewind Rewind', 'Mean Girls Neon', 'Spring Breakers', 'B2B Rave', 'Guess Underwear',
    'High Contrast Deluxe', 'Neon Lime Billboard', 'Boiler Room Live', 'Brat Minimal Mono', 'Cyber Lime Grid',
    'Brat Remix Edition', 'Vinyl Sleeve Green', 'Cassette Inset', 'Acid Album Art', 'Sweat Tour Live',
    'Subwoofer Bass', 'Club Haze', '365 Nights', 'Toxic Lime Glow', 'Charli Energy',
    'Party All Night', 'Lime Minimal Glow', 'Brat Poster 4:5', 'Pop Culture Icon', 'London Underground',
    'Berlin Basement', 'Hyperpop Cover', 'Bass Boosted Tape', 'Lime Matte Finish', 'Chart Topper',
    'Afterparty Vibe', 'Rave Flyer Lime', 'Vinyl Center Label', 'DJ Booth Monitor', 'Tracklist Backcover',
    'Deluxe Remaster', 'Strobe Lime Flash', 'Eurodance Beat', 'Underground Sound', 'Finale Brat Anthem'
  ];

  for (int i = 0; i < 50; i++) {
    final id = i + 1;
    final isWhite = i % 4 == 1;
    final isBlack = i % 4 == 2;
    final bg = isWhite
        ? Colors.white
        : (isBlack ? const Color(0xff121212) : const Color(0xff8ACE00));
    final border = isWhite
        ? const Color(0xff8ACE00)
        : (isBlack ? const Color(0xff8ACE00) : Colors.black);
    final textCol = isBlack ? Colors.white : Colors.black;
    final align = i % 5 == 0
        ? Alignment.bottomCenter
        : (i % 5 == 1
            ? Alignment.topCenter
            : (i % 5 == 2
                ? Alignment.bottomLeft
                : (i % 5 == 3 ? Alignment.center : Alignment.bottomRight)));
    final ratio = i % 6 == 0 ? 1.0 : (i % 6 == 1 ? 4 / 5 : (i % 6 == 2 ? 9 / 16 : 1.0));

    list.add(_f(
      id: id,
      name: bratNames[i],
      category: cat1,
      bg: bg,
      border: border,
      borderWidth: (i % 3 + 1) * 1.5,
      borderRadius: (i % 5) * 4.0,
      padding: EdgeInsets.fromLTRB(14, 14, 14, align == Alignment.bottomCenter ? 38 : 16),
      aspectRatio: ratio,
      caption: bratNames[i].toLowerCase(),
      captionFont: 'Arial',
      captionColor: textCol,
      captionSize: 13.0 + (i % 6) * 2,
      captionAlignment: align,
      overlayType: i % 7 == 0 ? FrameOverlayType.cdCase : FrameOverlayType.brat,
      hasFilmGrain: true,
    ));
  }

  // CATEGORY 2: 📸 Polaroid & Vintage (51 to 100)
  const cat2 = '📸 Polaroid & Vintage';
  final polNames = [
    'Classic Polaroid White', 'Darkroom Polaroid Noir', 'Sepia Sun Memory', 'Golden Hour Polaroid', 'Vintage Film Strip',
    '1998 Summer Nostalgia', 'Washi Tape Snapshot', 'Disposable 35mm', 'Analog Grain Memory', 'Kodak Warm 400',
    'Fuji Superia Film', 'Instant Wide Print', 'Mini Instax Border', 'Faded Memories', 'Warm Amber Glow',
    'Velvet Matte Print', 'CineStill 800T', 'Monochrome Silver', 'Polaroid 600 Square', 'Sunbleached 90s',
    'Retro Postcard', 'Film Border Black', '120 Medium Format', 'Dark Vignette Frame', 'Street Snapshot',
    'Nostalgia Trip', 'Matte Fine Paper', 'Glossy Photo Print', 'Pinhole Camera View', 'Overexposed Dream',
    'Film Burn Frame', 'Light Leak Glow', 'Double Exposure', 'Vintage Cream Border', 'Sepia Coastline',
    'Retro Beach Club', 'Roadtrip 1995', 'Dusty Slide View', 'Kodachrome 64', 'Analog Soul',
    'Candid Camera Shot', 'Photo Journal Cut', 'Vintage Date Stamp', 'Film Negative Edge', 'Archive Studio Print',
    'Scrapbook Clip Shot', 'Warm Golden Filter', 'Instant Film Frame', '35mm Roll Header', 'Heritage Snapshot'
  ];

  for (int i = 0; i < 50; i++) {
    final id = 51 + i;
    final isDark = i % 5 == 1;
    final isSepia = i % 5 == 2;
    final isFilmstrip = i % 4 == 0;
    final bg = isDark
        ? const Color(0xff1C1C1E)
        : (isSepia ? const Color(0xffF4ECD8) : Colors.white);
    final border = isDark ? Colors.white24 : (isSepia ? const Color(0xffD4C5A9) : Colors.black12);
    final textCol = isDark ? Colors.white70 : const Color(0xff2A2A2A);
    final align = i % 3 == 0 ? Alignment.bottomCenter : (i % 3 == 1 ? Alignment.bottomLeft : Alignment.topCenter);
    final ratio = i % 5 == 0 ? 1.0 : (i % 5 == 1 ? 4 / 5 : (i % 5 == 2 ? 3 / 4 : 1.0));

    final isDuo = i % 6 == 3;
    list.add(_f(
      id: id,
      name: isDuo ? '${polNames[i]} (2 Photos)' : polNames[i],
      category: cat2,
      bg: bg,
      border: border,
      borderWidth: 1.0,
      borderRadius: isFilmstrip ? 4.0 : 10.0,
      padding: EdgeInsets.fromLTRB(14, 14, 14, align == Alignment.bottomCenter ? 44 : 16),
      aspectRatio: ratio,
      caption: polNames[i],
      captionFont: i % 2 == 0 ? 'Courier Prime' : 'Playfair Display',
      captionColor: textCol,
      captionSize: 12.0 + (i % 4) * 2,
      captionAlignment: align,
      overlayType: isFilmstrip ? FrameOverlayType.filmstrip : FrameOverlayType.polaroid,
      hasFilmGrain: true,
      photoLayout: isDuo ? FramePhotoLayout.polaroidDuo : FramePhotoLayout.single,
      maxPhotos: isDuo ? 2 : 1,
    ));
  }

  // CATEGORY 3: 🎞️ Y2K & Digicam (101 to 150)
  const cat3 = '🎞️ Y2K & Digicam';
  final y2kNames = [
    'Cyber Digicam ISO 400', 'VHS Tape REC Glow', 'Windows 98 Dialog', 'Matrix Cyber Green', 'Y2K Metallic Silver',
    'Glitch Terminal CRT', 'Camcorder SP 00:00', 'CRT Monitor Glow', 'Digicam Focus Reticle', 'Cyber Y2K Chrome',
    'Win98 Error Popup', 'Mac Classic OS 8', 'Game Boy LCD Green', 'Tamagotchi Pixel', 'Flip Phone View 2003',
    'Cyber Neon Cyan', 'Holographic CD Lens', 'Dial-Up Internet', 'Millennium Bug 2000', 'Vaporwave Sunset',
    'Y2K Heart Reticle', 'Cyberpunk HUD Frame', 'Night Vision Cam', 'Low Battery Warning', 'Surveillance Feed',
    'VHS Static Glitch', '8-Bit Pixel Grid', 'Arcade CRT Screen', 'Digicam 2004 Model', 'Sony Cyber-shot Style',
    'Matrix Terminal Rain', 'Digital Camcorder HD', 'Flashbang White', 'Cyber Violet Aura', 'Y2K Cyber Angel',
    'Web 1.0 HTML Table', 'Cyber Silverware', 'Chrome Flame Border', 'Techno Core Y2K', 'Retro Webpage Border',
    'Pixelated Dream', 'Low Res Aesthetics', 'Digicam Night Mode', 'Y2K Pop Culture', 'Cybernetic Crosshair',
    'Digicam 10x Zoom', 'VHS SP LP Mode', 'Video Cassette Tape', 'Hacker Terminal Shell', 'Virtual Reality 90s'
  ];

  for (int i = 0; i < 50; i++) {
    final id = 101 + i;
    final isWin98 = i % 6 == 2;
    final isVhs = i % 4 == 1;
    final bg = isWin98
        ? const Color(0xffC0C0C0)
        : (i % 3 == 0 ? const Color(0xff0F172A) : const Color(0xff000000));
    final border = isWin98 ? const Color(0xff000080) : (i % 2 == 0 ? const Color(0xff8ACE00) : const Color(0xff00F0FF));
    final align = i % 4 == 0 ? Alignment.bottomCenter : (i % 4 == 1 ? Alignment.topCenter : Alignment.topLeft);
    final ratio = i % 4 == 0 ? 4 / 3 : (i % 4 == 1 ? 1.0 : (i % 4 == 2 ? 16 / 9 : 4 / 5));

    list.add(_f(
      id: id,
      name: y2kNames[i],
      category: cat3,
      bg: bg,
      border: border,
      borderWidth: isWin98 ? 3.0 : 1.5,
      borderRadius: isWin98 ? 0.0 : 8.0,
      padding: EdgeInsets.fromLTRB(12, isWin98 ? 30 : 12, 12, 12),
      aspectRatio: ratio,
      caption: isWin98 ? 'system_error.exe' : y2kNames[i],
      captionFont: isWin98 ? 'Courier Prime' : 'Press Start 2P',
      captionColor: isWin98 ? Colors.black : Colors.greenAccent,
      captionSize: 11.0,
      captionAlignment: align,
      overlayType: isWin98 ? FrameOverlayType.retroWindow : (isVhs ? FrameOverlayType.vhs : FrameOverlayType.digicam),
      hasFilmGrain: true,
    ));
  }

  // CATEGORY 4: 🎵 Music & Audio (151 to 200)
  const cat4 = '🎵 Music & Audio';
  final musNames = [
    'Spotify Now Playing', 'Apple Music Lyrics', 'Vinyl Record Center', 'Mixtape Cassette A', 'Soundcloud Waveform',
    'Billboard Hot 100', 'Album Tracklist Card', 'CD Jewel Case Glass', 'Podcast Quote Audio', 'Headphone Bass Boost',
    'DJ Deck Audio Pro', 'Turntable 33 RPM', 'Equalizer Bar Neon', 'Neon Audio Wave', 'Lo-Fi Chill Beats',
    'Bedroom Pop Tape', 'Radio Airplay Top 10', 'Acoustic Session Live', 'Live Concert Mic', 'Soundboard Studio',
    'Cassette Side B', 'Studio Monitor View', 'Vinyl Groove Ring', 'Audiophile Noir', 'Synthwave Jam Deck',
    'Bassline Drop Heavy', 'Top 50 Global Hit', 'Indie Band Mixtape', 'Festival All-Access', 'Backstage Laminate',
    'Boombox Retro 80s', 'Walkman Tape Player', 'Album Sleeve Gatefold', 'Song of Summer', 'Karaoke Lyrics Inset',
    'Repeat 1 Track Loop', 'Music Video Letterbox', 'Audio Spectrum Bar', 'Sub-Bass Resonance', 'Vinyl Single 45 RPM',
    'Remix Stems Master', 'Studio Master Tape', 'Streaming Mega Hit', 'Tube Amp Warmth', 'EP Teaser Poster',
    'Hit Single Cover', 'Gold Record Award', 'Platinum Disc Fame', 'Radio Frequency 104.2', 'Soundcheck Acoustic'
  ];

  for (int i = 0; i < 50; i++) {
    final id = 151 + i;
    final isCD = i % 4 == 1;
    final bg = i % 3 == 0 ? const Color(0xff121212) : (i % 3 == 1 ? const Color(0xff1E1E2E) : Colors.black);
    final border = i % 2 == 0 ? const Color(0xff8ACE00) : const Color(0xff1DB954);
    final align = i % 3 == 0 ? Alignment.bottomCenter : (i % 3 == 1 ? Alignment.topCenter : Alignment.bottomLeft);
    final ratio = i % 5 == 0 ? 1.0 : (i % 5 == 1 ? 4 / 5 : (i % 5 == 2 ? 9 / 16 : 1.0));

    list.add(_f(
      id: id,
      name: musNames[i],
      category: cat4,
      bg: bg,
      border: border,
      borderWidth: 2.0,
      borderRadius: 12.0,
      padding: EdgeInsets.fromLTRB(14, 14, 14, align == Alignment.bottomCenter ? 46 : 16),
      aspectRatio: ratio,
      caption: '▶  ${musNames[i]}',
      captionFont: 'Inter',
      captionColor: Colors.white,
      captionSize: 13.0,
      captionAlignment: align,
      overlayType: isCD ? FrameOverlayType.cdCase : FrameOverlayType.musicPlayer,
      hasFilmGrain: false,
    ));
  }

  // CATEGORY 5: ✨ Acid & Rave Neon (201 to 250)
  const cat5 = '✨ Acid & Rave Neon';
  final acidNames = [
    'Acid Neon Highlighter', 'Cyberpunk Hot Pink', 'Electric Cyan Shock', 'Toxic Radioactive Lime', 'Rave Flyer Warehouse',
    'Trippy Checkerboard', 'Ultraviolet Blacklight', 'Laser Strobe Green', 'Techno Bunker Berlin', 'Acid Smiley Cyber',
    'Fluorescent Blast', 'Neon Hazard Stripe', 'Cyber Magenta Pulse', 'Acid Wash Denim', 'Hyperpop Rave Glow',
    'Psychedelic Vortex', 'VIP Rave Ticket', 'High Voltage Neon', 'Cyber Matrix Flash', 'Acid Rain Cyberpunk',
    'Glowstick Rave 3AM', 'Electric Violet Glow', 'Rave Energy Drink', 'Neon Circuit Board', 'Strobe Pulse 140BPM',
    'Acid Sun Horizon', 'Cyber Alien Radio', 'Neon Prism Beam', 'High Energy Anthem', 'Rave Poster 1999',
    'Toxic Slime Green', 'Ultraviolet Flash', 'Acid Pop Candy', 'Laser Grid Arena', 'Rave Anthem Drop',
    'Neon Barricade Tape', 'Electric Jungle Rave', 'Cyber Acid Trip', 'Acid Swirl Tie-Dye', 'Neon Flame Border',
    'Radioactive Hazard', 'Rave Bunker Vault', 'Cyber Wave Runner', 'Neon Cyberpunk City', 'Acid Hallucination',
    'Electric Dream State', 'Techno Tribe Ritual', 'Neon Sunrise Chill', 'Rave Culture Pure', 'Euphoria Mainstage'
  ];

  for (int i = 0; i < 50; i++) {
    final id = 201 + i;
    final colors = [
      const Color(0xff39FF14),
      const Color(0xffFF007F),
      const Color(0xff00F0FF),
      const Color(0xffFFFF00),
      const Color(0xff8338EC),
    ];
    final neonCol = colors[i % colors.length];
    final bg = i % 2 == 0 ? const Color(0xff0A0A0C) : const Color(0xff18181B);
    final align = i % 4 == 0 ? Alignment.bottomCenter : (i % 4 == 1 ? Alignment.topCenter : Alignment.center);
    final ratio = i % 4 == 0 ? 1.0 : (i % 4 == 1 ? 4 / 5 : (i % 4 == 2 ? 9 / 16 : 1.0));

    list.add(_f(
      id: id,
      name: acidNames[i],
      category: cat5,
      bg: bg,
      border: neonCol,
      borderWidth: 3.5,
      borderRadius: 16.0,
      padding: const EdgeInsets.all(16.0),
      aspectRatio: ratio,
      caption: '✦ ${acidNames[i].toUpperCase()} ✦',
      captionFont: 'Rubik Vinyl',
      captionColor: neonCol,
      captionSize: 13.0,
      captionAlignment: align,
      overlayType: i % 3 == 0 ? FrameOverlayType.hazard : FrameOverlayType.none,
      hasFilmGrain: true,
    ));
  }

  // CATEGORY 6: 🖤 Minimal & Editorial (251 to 300)
  const cat6 = '🖤 Minimal & Editorial';
  final minNames = [
    'Vogue Editorial Clean', 'Swiss Graphic Grid', 'Museum Gallery Mat', 'Bauhaus Stark Black', 'High Fashion Noir',
    'Minimal White Border', 'Monolith Dark Frame', 'Tokyo Modernist', 'Architect Blueprint', 'Sans-Serif Brutalism',
    'Editorial Split Grid', 'Stark White Paper', 'Matte Black Void', 'Fine Art Gallery Frame', 'Gallery White Passepartout',
    'Modernist Clean Line', 'Brutalist Card Post', 'Minimalist Mono Post', 'Clean Typo Layout', 'Art Exhibition Card',
    'Haute Couture Story', 'Architecture Daily', 'Serif Minimal Cover', 'Blank Negative Space', 'Crisp White Border',
    'Slate Gray Texture', 'Pure Geometry Frame', 'Scandinavian Clean', 'Minimalist Caption Bar', 'Design Studio Monograph',
    'Monochromatic Chic', 'Helvetica Swiss Style', 'Editorial Magazine Spread', 'Negative Space Poster', 'Chic Monochrome Square',
    'Black Hairline Border', 'Ivory Heavy Paper', 'Luxury Fashion Brand', 'Simple Typographic Statement', 'Minimalist Noir Gallery',
    'Studio Portrait Clean', 'Clean White Canvas', 'Bold Editorial Subtitle', 'Minimalist Modern Post', 'Editorial Focus Frame',
    'Quiet Luxury Aesthetic', 'Editorial Story 9:16', 'Fine Lines Precision', 'Modern Art Gallery Wall', 'Pure Contrast Noir'
  ];

  for (int i = 0; i < 50; i++) {
    final id = 251 + i;
    final isDark = i % 2 == 1;
    final bg = isDark ? const Color(0xff121212) : Colors.white;
    final border = isDark ? Colors.white30 : Colors.black12;
    final textCol = isDark ? Colors.white : Colors.black;
    final align = i % 3 == 0 ? Alignment.bottomLeft : (i % 3 == 1 ? Alignment.bottomCenter : Alignment.topLeft);
    final ratio = i % 4 == 0 ? 4 / 5 : (i % 4 == 1 ? 1.0 : (i % 4 == 2 ? 3 / 4 : 9 / 16));

    list.add(_f(
      id: id,
      name: minNames[i],
      category: cat6,
      bg: bg,
      border: border,
      borderWidth: 0.8,
      borderRadius: 0.0,
      padding: const EdgeInsets.all(22.0),
      aspectRatio: ratio,
      caption: minNames[i],
      captionFont: i % 2 == 0 ? 'Playfair Display' : 'Oswald',
      captionColor: textCol,
      captionSize: 13.0,
      captionAlignment: align,
      overlayType: FrameOverlayType.minimal,
      hasFilmGrain: false,
    ));
  }

  // CATEGORY 7: 📐 Collage, Strips & Stamps (301 to 350)
  const cat7 = '📐 Collage, Strips & Stamps';
  final colNames = [
    'Photobooth 3-Strip Classic', 'Photobooth 4-Grid Square', 'Postage Stamp Serrated', 'Vintage Airmail Edge', 'Diary Scrapbook Tape',
    'Filmstrip 35mm Roll', 'Passport Photo Grid', 'Sticker Collage Border', 'Ticket Stub Memorabilia', 'Comic Book Panel Strip',
    'Stamp Collector Edition', 'Retro Airmail Post', 'Japanese Stamp Border', 'Photobooth Love Strip', 'Photo Strip Noir Film',
    'Scrapbook Corner Tape', 'Memory Board Collage', 'Tape Polaroid Duo', 'Vintage Envelope Mat', 'Postage Label Vintage',
    'Photo Grid 2x2 Clean', 'Contact Sheet 35mm', 'Film Roll Header Cut', 'Postcard Back Card', 'Paperclip Sheet Journal',
    'Boarding Pass Ticket', 'Cine Strip 70mm', 'Collage Duo Split', 'Scrapbook Diary Entry', 'Stamp Border Neon Pink',
    'Vintage Postmark Stamp', 'Polaroid Duo Side by Side', 'Mini Film Strip', 'Film Sprocket Border', 'Photobooth Party Fun',
    'Stamp Border Lime', 'Fine Art Postage Stamp', 'Envelope Wax Seal', 'Photo Strip Trio', 'Collector Card Foil',
    'Scrapbook Kraft Paper', 'Collage Quad Grid', 'Retro Event Badge', 'Stamp Noir Matte', 'Postage Blue Express',
    'Photobooth Romance', 'Collage Border Chic', 'Ticket Barcode Strip', 'Memory Strip Film', 'Vintage Keepsake Album'
  ];

  for (int i = 0; i < 50; i++) {
    final id = 301 + i;
    final isStamp = i % 3 == 0;
    final isStrip = i % 3 == 1;
    final bg = isStamp ? const Color(0xffFAF8F5) : (isStrip ? const Color(0xff18181B) : Colors.white);
    final border = isStamp ? const Color(0xffE2DACD) : (isStrip ? Colors.white24 : Colors.black12);
    final textCol = isStrip ? Colors.white : Colors.black87;
    final align = i % 2 == 0 ? Alignment.bottomCenter : Alignment.topCenter;
    final ratio = isStrip ? 3 / 4 : (isStamp ? 1.0 : (i % 3 == 0 ? 4 / 5 : 1.0));

    FramePhotoLayout photoLayout = FramePhotoLayout.single;
    int maxPhotos = 1;
    if (i % 6 == 0) {
      photoLayout = FramePhotoLayout.filmstrip3;
      maxPhotos = 3;
    } else if (i % 6 == 1) {
      photoLayout = FramePhotoLayout.grid4;
      maxPhotos = 4;
    } else if (i % 6 == 2) {
      photoLayout = FramePhotoLayout.split2H;
      maxPhotos = 2;
    } else if (i % 6 == 3) {
      photoLayout = FramePhotoLayout.polaroidDuo;
      maxPhotos = 2;
    } else if (i % 6 == 4) {
      photoLayout = FramePhotoLayout.triptych3;
      maxPhotos = 3;
    }

    list.add(_f(
      id: id,
      name: colNames[i],
      category: cat7,
      bg: bg,
      border: border,
      borderWidth: 1.5,
      borderRadius: isStamp ? 18.0 : 8.0,
      padding: EdgeInsets.fromLTRB(14, isStrip ? 20 : 14, 14, 20),
      aspectRatio: ratio,
      caption: colNames[i],
      captionFont: 'Courier Prime',
      captionColor: textCol,
      captionSize: 11.5,
      captionAlignment: align,
      overlayType: isStamp ? FrameOverlayType.stamp : (isStrip ? FrameOverlayType.filmstrip : FrameOverlayType.none),
      hasFilmGrain: true,
      photoLayout: photoLayout,
      maxPhotos: maxPhotos,
    ));
  }

  // CATEGORY 8: 💬 Quotes & Viral Memes (351 to 400)
  const cat8 = '💬 Quotes & Viral Memes';
  final quoteNames = [
    'Viral Tweet Card Clean', 'Notes App Confession', 'iMessage Blue Bubble', 'Meme Top & Bottom Text', 'Dialogue Movie Subtitle',
    'Daily Reminder Card', 'Gossip Text Leak', 'Mood Status Update', 'Overheard in City', 'Savage Clapback Card',
    'Tweet Dark Mode Card', 'Notes App Apology', 'iMessage Green Bubble', 'Viral TikTok Sound Quote', 'Caption Bar Noir',
    'Quote of the Day Card', 'Unsent Message Draft', 'Subtitle Cinematic Yellow', 'Movie Scene Noir Film', 'Push Notification Alert',
    'Tweet Verified Badge', 'Meme Impact Style Classic', 'Daily Affirmation Poster', 'Honest 1-Star Review', 'Text Message Screenshot',
    'Status Story 9:16', 'Relatable Content Meme', 'Late Night Thoughts', 'Direct Message Leak', 'Chat Bubble Pink Sweet',
    'Quote Retweet Card', 'Voice Memo Recording', 'Meme Strip Headline', 'Confession Wall Post', 'Pop Culture Quote',
    'Message Delivered Sent', 'Sarcastic Humor Post', 'Group Chat Gossip', 'Notification Banner Bar', 'Meme Header Classic',
    'Dialogue Box RPG Retro', 'Tweet Card Pure White', 'Story Poll Prompt', 'Quote Poster Vintage', 'Moodboard Text Card',
    'Viral Comment Highlight', 'Forum Top Discussion', 'Story Quote Highlight', 'Tweet Thread Part 1', 'Meme Punchline Final'
  ];

  for (int i = 0; i < 50; i++) {
    final id = 351 + i;
    final isDark = i % 3 == 0;
    final bg = isDark ? const Color(0xff15181C) : (i % 3 == 1 ? Colors.white : const Color(0xffF8FAFC));
    final border = isDark ? Colors.white24 : const Color(0xffE2E8F0);
    final textCol = isDark ? Colors.white : Colors.black87;
    final align = i % 4 == 0 ? Alignment.bottomCenter : (i % 4 == 1 ? Alignment.topCenter : Alignment.center);
    final ratio = i % 4 == 0 ? 1.0 : (i % 4 == 1 ? 4 / 5 : (i % 4 == 2 ? 16 / 9 : 1.0));

    list.add(_f(
      id: id,
      name: quoteNames[i],
      category: cat8,
      bg: bg,
      border: border,
      borderWidth: 1.2,
      borderRadius: 14.0,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      aspectRatio: ratio,
      caption: quoteNames[i],
      captionFont: i % 2 == 0 ? 'Inter' : 'Bebas Neue',
      captionColor: textCol,
      captionSize: 13.0,
      captionAlignment: align,
      overlayType: FrameOverlayType.none,
      hasFilmGrain: false,
    ));
  }

  // CATEGORY 9: 🌈 Pastel & Moodboard (401 to 450)
  const cat9 = '🌈 Pastel & Moodboard';
  final pastelNames = [
    'Soft Peach Cream', 'Lilac Dream Lavender', 'Matcha Mint Foam', 'Baby Blue Cloud', 'Butter Yellow Sunshine',
    'Blush Pink Romance', 'Warm Sand Beige', 'Cozy Coffee Shop', 'Pastel Sunset Glow', 'Cotton Candy Sky',
    'Pistachio Cream Soft', 'Lavender Haze Aura', 'Rosy Cheeks Pastel', 'Soft Vanilla Cream', 'Morning Mist Pale',
    'Peach Sorbet Sweet', 'Sage Green Cozy', 'Aesthetic Neutral Card', 'Pastel Rainbow Gradient', 'Golden Honey Glow',
    'Strawberry Milk Carton', 'Clean Girl Minimal Pastel', 'Soft Apricot Velvet', 'Mint Macaron Parisian', 'Sunset Pastel Palette',
    'Powder Blue Breeze', 'Oat Milk Latte Beige', 'Cozy Autumn Pastel', 'Pastel Grid Aesthetic', 'Dreamy Bloom Garden',
    'Soft Shadow Afternoon', 'Cloud Nine Whimsical', 'Linen Fabric Texture', 'Warm Ivory Elegance', 'Cherry Blossom Tokyo',
    'Pastel Collage Duo', 'Sunlit Room Window', 'Soft Focus Dream', 'Morning Coffee Table', 'Buttercream Whipped',
    'Rose Gold Whisper', 'Pastel Gradient Sky', 'Cozy Blanket Morning', 'Aesthetic Diary Journal', 'Soft Lemon Meringue',
    'Dusty Rose Petals', 'Vanilla Cloud Velvet', 'Lavender Mist Forest', 'Pastel Moodboard Studio', 'Serene Morning Meditation'
  ];

  final pastelColors = [
    const Color(0xffFCE7D2), // Peach
    const Color(0xffE9D5FF), // Lilac
    const Color(0xffD1FAE5), // Mint
    const Color(0xffBAE6FD), // Sky
    const Color(0xffFEF08A), // Butter
    const Color(0xffFBCFE8), // Blush
    const Color(0xffFDE68A), // Honey
  ];

  for (int i = 0; i < 50; i++) {
    final id = 401 + i;
    final bg = pastelColors[i % pastelColors.length];
    final border = Colors.white;
    const textCol = Color(0xff2D3748);
    final align = i % 3 == 0 ? Alignment.bottomCenter : (i % 3 == 1 ? Alignment.topLeft : Alignment.bottomRight);
    final ratio = i % 4 == 0 ? 1.0 : (i % 4 == 1 ? 4 / 5 : (i % 4 == 2 ? 3 / 4 : 1.0));

    list.add(_f(
      id: id,
      name: pastelNames[i],
      category: cat9,
      bg: bg,
      border: border,
      borderWidth: 4.0,
      borderRadius: 18.0,
      padding: const EdgeInsets.all(16.0),
      aspectRatio: ratio,
      caption: pastelNames[i],
      captionFont: 'Caveat',
      captionColor: textCol,
      captionSize: 15.0,
      captionAlignment: align,
      overlayType: FrameOverlayType.none,
      hasFilmGrain: false,
    ));
  }

  // CATEGORY 10: ⚡ Social Story & Reels (451 to 500)
  const cat10 = '⚡ Social Story & Reels';
  final storyNames = [
    'Insta Story Full 9:16', 'TikTok Trend Overlay', 'Reels Portrait 9:16', 'Streetwear Drop Hype', 'Breaking News Banner',
    'Party Invite Nightclub', 'Live Stream VIP Frame', 'Daily Vlog Teaser', 'Event Countdown Story', 'Hypebeast Poster 9:16',
    'Story Question Box', 'TikTok Sound Waveform', 'Reels Audio Drop Story', 'Flash Sale Banner 9:16', 'VIP Pass Story Card',
    'Live Concert Streamer', 'Story Highlight Cover', 'Sneaker Drop Hypebeast', 'Festival Lineup Poster', 'Story Swipe Up Prompt',
    'Trending Audio Now', 'Story Interactive Poll', 'Event Flyer 9:16 Clean', 'Reel Video Thumbnail', 'Breaking News Alert',
    'Story Quiz Challenge', 'Club Night Promo 9:16', 'Limited Drop Alert', 'Story Reaction Cam', 'TikTok Duet Portrait',
    'Daily Life Story 9:16', 'Story Inset Photo Card', 'Streetwear Tag Poster', 'Story Collage Duo 9:16', 'Music Story Soundwave',
    'Story Sticker Pack Look', 'Hype Story Announcement', 'Live Broadcast Banner', 'Story Frame Cyber Neon', 'Reels Spotlight Star',
    'Event Date Story Card', 'Party All Night 9:16', 'Story Filmstrip Vertical', 'Sneakerhead Hype Post', 'Story Minimalist 9:16',
    'Tour Dates Poster Story', 'Exclusive VIP Drop', 'Story Gradient Glow', 'Reel Viral Hook Card', 'Social Media Super Hype'
  ];

  for (int i = 0; i < 50; i++) {
    final id = 451 + i;
    final isDark = i % 2 == 0;
    final bg = isDark ? const Color(0xff09090B) : const Color(0xff18181B);
    final border = i % 3 == 0 ? const Color(0xff8ACE00) : (i % 3 == 1 ? const Color(0xffFF007F) : Colors.white24);
    final textCol = Colors.white;
    final align = i % 4 == 0 ? Alignment.bottomCenter : (i % 4 == 1 ? Alignment.topCenter : Alignment.center);
    final ratio = i % 4 == 3 ? 4 / 5 : 9 / 16;

    list.add(_f(
      id: id,
      name: storyNames[i],
      category: cat10,
      bg: bg,
      border: border,
      borderWidth: 2.0,
      borderRadius: 14.0,
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 24.0),
      aspectRatio: ratio,
      caption: storyNames[i],
      captionFont: 'Oswald',
      captionColor: textCol,
      captionSize: 14.0,
      captionAlignment: align,
      overlayType: i % 4 == 0 ? FrameOverlayType.vhs : FrameOverlayType.none,
      hasFilmGrain: true,
    ));
  }

  return list;
}

final List<FrameTemplate> predefined500Frames = _generate500Catalog();
final List<FrameTemplate> predefined100Frames = predefined500Frames;
