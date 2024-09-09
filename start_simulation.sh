#!/bin/bash
#Miguel Rosas

# Lista de valores para a
valores_a=("0" "0.05" "0.07" "0.25" "0.3" "0.42" "0.435" "0.6" "0.7" "0.8" "0.82" "1" "1.088" "1.17" "1.18" "1.2" "1.4" "1.56" "1.58" "1.8")
# valores_a=("0.025" "0.06" "0.16" "0.275" "0.36" "0.4275" "0.5175" "0.65" "0.75" "0.81" "0.91" "1.044" "1.129" "1.19" "1.3" "1.48" "1.57" "1.69")

# Leer valores desde el archivo parametros.txt
n=$(grep -oP 'n\s*=\s*\K[\d.+-]+' parameters.txt)

# Verifica si se proporciona la cantidad como argumento
if [ $# -eq 0 ]; then
  echo "Uso: $0 cantidad"
  exit 1
fi

# Obtiene la cantidad desde el primer argumento
cantidad=$1

# Bucle para crear y mover carpetas, editar y genrar mallado
for ((i = 1; i <= $cantidad; i++)); do
  # Genera el nombre de la carpeta
  nombre_carpeta="Case_$i"

  # Crea la carpeta del caso
  mkdir "$nombre_carpeta"

  # Copia carpetas del caso dentro de las carpetasgeneradas
  cp -r "Case_0/0/" "$nombre_carpeta/"
  cp -r "Case_0/0.orig/" "$nombre_carpeta/"
  cp -r "Case_0/constant/" "$nombre_carpeta/"
  cp -r "Case_0/system/" "$nombre_carpeta/"
  cp "Case_0/extract_freesurface_plane.py" "$nombre_carpeta/"
  cp "Case_0/extract_freesurface.sh" "$nombre_carpeta/"
  cp "Case_0/extractor.py" "$nombre_carpeta/"

  ddir=$(pwd)
  sed -i "s|\$ddir|$ddir|g" "./$nombre_carpeta/extract_freesurface_plane.py"

  # Realiza el intercambio en el archivo
  valor_a="${valores_a[i - 1]}"
  sed -i "s/\$aa/$valor_a/g" "$nombre_carpeta/system/setFieldsDict"
  sed -i "s/\$aa/$valor_a/g" "$nombre_carpeta/extractor.py"
  sed -i "s/\$i/$i/g" "$nombre_carpeta/extract_freesurface_plane.py"
  sed -i "s/\$i/$i/g" "$nombre_carpeta/extractor.py"
  sed -i "s/\$nn/$n/g" "$nombre_carpeta/constant/porosityProperties"
  sed -i "s/\$nn/$n/g" "$nombre_carpeta/system/setFieldsDict"

  cd "$nombre_carpeta/"

  blockMesh
  setFields
  decomposePar
  mpirun -np 6 interIsoFoam -parallel >log
  kitty --hold -e bash -c "./extract_freesurface.sh && python3 extractor.py && rm -r ./proce*; exec bash" &
  cd ..
done

echo "Proceso completado."
