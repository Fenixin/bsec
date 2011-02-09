#!/bin/bash

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

##############################################################################
#
# Este script emplea rsync para hacer copias de seguridad acumulativas.
#
# El script coge EL CONTENIDO de la carpeta de origen y la copia en la carpeta destino en una nueva carpeta con nombre
# la fecha actual. En la copia se hace uso de hard links con la carpeta con fecha más cercana a la actual.
#
# Su licencia es GNU GPL... y no me responsabilizo de los desastres que pueda causar.
#
# Su uso es: "./bsec.sh <carpeta de origen> <carpeta de destino>
# Donde la carpeta de origen es la carpeta de la que queremos hacer la copia de seguridad
# y la carpeta de destino contiene carpetas con fechas a las cuales se puede linkear
# la copia de seguridad que se va a hacer ahora.
#


# Primero comprobamos que no nos está pidiendo ayuda, para ello comprobamos que el comando es -h o que ha introducido alguna
# barbaridad típica de usuario.

if [ "$1" = "-h" ]
  then
  echo "El script coge EL CONTENIDO de la carpeta de origen y la copia en la carpeta destino en una nueva carpeta con nombre la fecha actual. En la copia se hace uso de hard links con la carpeta con fecha más cercana a la actual."
  exit 0
  exit
elif [ $# -ne 2 ]
  then
  echo "Escribe bsec.sh [ORIGEN] [DESTINO] o -h para ayuda"
  exit 0
  exit
fi

# Procedemos a designar variables.

ORIGEN=$1
DESTINO=$2

# Comprobamos que origen es carpeta y destino también.

if [ ! -d "$ORIGEN" ]
  then
  echo "Origen no es un directorio válido!"
  exit 0
  exit
fi

if [ ! -d $DESTINO ]
  then
  echo "Destino no es un directorio válido!"
  exit 0
  exit
fi

# Como copiará el contenido de la carpeta origen hay que comprobar que la variable origen termina en / y si no es así añadirle la barra.

if [ ! ${ORIGEN:(-1):1} = / ]
  then
#  echo "Estoy añadiendo una barra!!"
  ORIGEN=$ORIGEN/
#  echo $ORIGEN
fi

if [ ! ${DESTINO:(-1):1} = / ]
  then
#  echo "Estoy añadiendo una barra!!"
  DESTINO=$DESTINO/
#  echo $DESTINO 
fi

# Ahora buscamos posibles backups anteriores a los que linkear la nueva backup

LINKEO=`ls $DESTINO | sort | tail -n 1`
#echo $LINKEO
LINKEO=$DESTINO$LINKEO
#echo $LINKEO

# Comprobamos que realmente linkeo es un directorio

if [ ! -d "$LINKEO" ]
  then
  echo "$LINKEO que no es más que LINKEO no es un directorio válido!"
  echo $LINKEO
  exit 0
  exit
fi

# Ponemos a "" LINKEO si no hay carpetas anteriores

if [ "$LINKEO" = "$DESTINO" ]
  then
  LINKEO=""
fi

# Con los dos directorios preparados hay que añadir al directorio destino la fecha actual.

DESTINO=$DESTINO`date +%Y.%m.%d`

# Ya podemos invocar el comando rsync!

if [ "$LINKEO" = "$DESTINO" -o "$LINKEO" = "" ]
  then  
  rsync -avP "$ORIGEN" "$DESTINO"
  USADO="rsync -avP "$ORIGEN" "$DESTINO""
else
  rsync -avP --link-dest="$LINKEO" "$ORIGEN" "$DESTINO"
  USADO="rsync -avP --link-dest="$LINKEO" "$ORIGEN" "$DESTINO""
fi

echo $USADO

exit 0
exit
