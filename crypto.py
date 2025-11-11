from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.backends import default_backend
import os
from os import urandom


def generar_clave_y_iv():
    """genera una clave AES de 32 bytes (AES-256) y un Iv de 16 bytes."""
    key = urandom(32) # 32 bytes para AES-256
    iv = urandom(16) # 16 bytes para el IV
    return key, iv

def encriptar(texto_plano, key, iv):
    """Encriptar texto plano usando AES en modo CBC. """
    cipher = Cipher(algorithms.AES(key), modes.CBC(iv), backend=default_backend())
    encryptor = cipher.encryptor()

#Padding para que el texto tenga una longitud que sea multiplo del
#tamaño del bloque AES (16bytes)
#Esto es necesario para algunos modos de cifrado como CBC

def encriptar(texto_plano, key, iv):
    texto_plano_bytes = texto_plano.encode('utf-8')
    padding_length = 16 - (len(texto_plano_bytes) % 16)
    padding = bytes([padding_length]) * padding_length
    texto_a_cifrar = texto_plano_bytes + padding

    cipher = Cipher(algorithms.AES(key), modes.CBC(iv), backend=default_backend())
    encryptor = cipher.encryptor()
    texto_cifrado = encryptor.update(texto_a_cifrar) + encryptor.finalize()

    return texto_cifrado


def desencriptar(texto_cifrado, key, iv):
    """Desencripta texto cifrado usando AES en modo CBC."""
    cipher = Cipher(algorithms.AES(key), modes.CBC(iv), backend=default_backend())
    decryptor = cipher.decryptor()
    texto_desencriptado_con_padding = decryptor.update(texto_cifrado) + decryptor.finalize()

    # Eliminar el padding
    padding_length = texto_desencriptado_con_padding[-1]
    texto_desencriptado = texto_desencriptado_con_padding[:-padding_length]

    return texto_desencriptado.decode('utf-8')


# --- Función para encriptar ---
def encriptar(texto_plano, key, iv):
    texto_plano_bytes = texto_plano.encode('utf-8')
    padding_length = 16 - (len(texto_plano_bytes) % 16)
    padding = bytes([padding_length]) * padding_length
    texto_a_cifrar = texto_plano_bytes + padding

    cipher = Cipher(algorithms.AES(key), modes.CBC(iv), backend=default_backend())
    encryptor = cipher.encryptor()
    texto_cifrado = encryptor.update(texto_a_cifrar) + encryptor.finalize()

    return texto_cifrado


# --- Función para desencriptar ---
def desencriptar(texto_cifrado, key, iv):
    """Desencripta texto cifrado usando AES en modo CBC."""
    cipher = Cipher(algorithms.AES(key), modes.CBC(iv), backend=default_backend())
    decryptor = cipher.decryptor()
    texto_desencriptado_con_padding = decryptor.update(texto_cifrado) + decryptor.finalize()

    # --- Eliminar el padding ---
    padding_length = texto_desencriptado_con_padding[-1]
    texto_desencriptado = texto_desencriptado_con_padding[:-padding_length]
    return texto_desencriptado.decode('utf-8')


# --- Generar clave e IV ---
def generar_clave_y_iv():
    key = os.urandom(16)  # 16 bytes = 128 bits
    iv = os.urandom(16)   # 16 bytes = tamaño de bloque AES
    return key, iv


# --- Uso ---
# 1. Generar clave y IV (normalmente se guardan para usarse después)
key, iv = generar_clave_y_iv()

# 2. Texto original
texto_original = "Este es un mensaje secreto."

# 3. Encriptar el mensaje
texto_encriptado = encriptar(texto_original, key, iv)
print(f"Texto encriptado: {texto_encriptado}")

# 4. Desencriptar el mensaje
texto_desencriptado = desencriptar(texto_encriptado, key, iv)
print(f"Texto desencriptado: {texto_desencriptado}")