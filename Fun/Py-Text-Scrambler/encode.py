import base64


def encode_to_hex(text: str) -> str:
    ''' Converts text to hex using ASCII encoding
    Args: text: str
    Returns: str
    '''
    return text.lower().encode('ASCII').hex()


def encode_to_base64(text: str) -> str:
    ''' Converts text to base64 using ASCII encoding
    Args: text: str
    Returns: str
    '''
    return base64.b64encode(text.encode('ASCII')).decode('ASCII')


def main(text: str) -> str:
    ''' Converts text to hex and then to base64
    Args: text: str
    Returns: str
    '''
    # Convert text to hex
    text_in_hex = encode_to_hex(text)
    print(f'Hex of text: {text_in_hex}')

    # Convert hex to base64
    text_in_hex_in_base64 = encode_to_base64(text_in_hex)
    print(f'Base64 of hex of text: {text_in_hex_in_base64}')

    return text_in_hex_in_base64


if __name__ == '__main__':
    # Get text from user
    text = str(input("Enter text to convert: "))

    # use default text("Hello, World!") if no input
    if not text:
        text = 'Hello, World!'

    print(f'Using Text: {text}')

    # Convert text to hex and then to base64
    main(text)
