#!/usr/bin/env python3
"""
Convierte el icono SVG a PNG en diferentes tamaños
"""
import subprocess
import sys

def convert_svg_to_png(svg_file, png_file, size):
    """Convierte SVG a PNG usando diferentes métodos"""

    # Método 1: Intentar con rsvg-convert (si está instalado)
    try:
        subprocess.run([
            'rsvg-convert',
            '-w', str(size),
            '-h', str(size),
            svg_file,
            '-o', png_file
        ], check=True)
        print(f"✓ Creado {png_file} ({size}x{size}) con rsvg-convert")
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        pass

    # Método 2: Intentar con ImageMagick
    try:
        subprocess.run([
            'convert',
            '-background', 'none',
            '-resize', f'{size}x{size}',
            svg_file,
            png_file
        ], check=True)
        print(f"✓ Creado {png_file} ({size}x{size}) con ImageMagick")
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        pass

    # Método 3: Intentar con Inkscape
    try:
        subprocess.run([
            'inkscape',
            '--export-type=png',
            f'--export-width={size}',
            f'--export-height={size}',
            '--export-filename=' + png_file,
            svg_file
        ], check=True, capture_output=True)
        print(f"✓ Creado {png_file} ({size}x{size}) con Inkscape")
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        pass

    # Método 4: Usar Python con cairosvg
    try:
        import cairosvg
        cairosvg.svg2png(
            url=svg_file,
            write_to=png_file,
            output_width=size,
            output_height=size
        )
        print(f"✓ Creado {png_file} ({size}x{size}) con cairosvg")
        return True
    except ImportError:
        pass
    except Exception as e:
        print(f"Error con cairosvg: {e}")

    print(f"✗ No se pudo convertir {svg_file} a {png_file}")
    print("Instala una de estas herramientas:")
    print("  - pip install cairosvg")
    print("  - sudo apt-get install librsvg2-bin")
    print("  - sudo apt-get install imagemagick")
    print("  - sudo apt-get install inkscape")
    return False

if __name__ == '__main__':
    svg_file = 'icon_duolingo.svg'

    # Convertir a diferentes tamaños
    sizes = {
        'icons/Icon-192.png': 192,
        'icons/Icon-512.png': 512,
        'icons/Icon-maskable-192.png': 192,
        'icons/Icon-maskable-512.png': 512,
        'favicon.png': 32
    }

    success = 0
    for png_file, size in sizes.items():
        if convert_svg_to_png(svg_file, png_file, size):
            success += 1

    print(f"\n{success}/{len(sizes)} iconos convertidos exitosamente")
    sys.exit(0 if success == len(sizes) else 1)
