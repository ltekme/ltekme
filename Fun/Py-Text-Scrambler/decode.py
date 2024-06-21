import base64


def decode_from_hex(text: str) -> str:
    ''' Converts hex to text using ASCII encoding
    Args: text: str
    Returns: str
    '''
    return bytearray.fromhex(text.lower()).decode()


def decode_from_base64(text: str) -> str:
    ''' Converts base64 to text using ASCII encoding.    
    Args: text: str
    Returns: str
    '''
    # Accomidate for missing "="
    text += "=" * int(4 - (len(text) % 4))

    return base64.b64decode(text).decode('ASCII')


def main(text: str) -> str:
    ''' Converts base64 to hex and then to text
    Args: text: str
    Returns: str
    '''
    # Convert base64 to hex
    base64_encoded_text = decode_from_base64(text)
    print(f'Hex of Base64: {base64_encoded_text}')

    # Convert hex to text
    hex_encoded_text = decode_from_hex(base64_encoded_text)
    print(f'Text of Hex of Base64: {hex_encoded_text}')

    return hex_encoded_text


if __name__ == '__main__':
    # Get text from user
    text = str(input("Enter Base64 to convert: "))

    # use default text("NDg2NTZjNmM2ZjJjMjA1NzZmNzI2YzY0MjE=") if no input
    if not text:
        text = 'NDg2NTZjNmM2ZjJjMjA1NzZmNzI2YzY0MjE='

    print(f'Using Base: {text}')

    # Convert base64 to hex and then to text
    main(text)
