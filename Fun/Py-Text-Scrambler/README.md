# Python Text Scrambler

Not really. A small snippet of code I that I use to embed some message in a way that is not overious.

One of my uses are making the hostname of my routers.

I know, useless.

## Useage - Encoding

To encode text to hex then to base64, execute `encode.py`

The following prompt will show up

```bash
python encode.py
> Enter text to convert: 
```

Enter the text to be converted into the prompt and press enter

A list of output in the terminal will be shown

```sh
python encode.py
> Enter text to convert: Hello, World!
> Using Text: Hello, World!
> Hex of text: 48656c6c6f2c20576f726c6421
> Base64 of hex of text: NDg2NTZjNmM2ZjJjMjA1NzZmNzI2YzY0MjE=
```

When no input is provided. `Hello, World!` will be used

```bash
python encode.py
> Enter text to convert: 
> Using Text: Hello, World!
> Hex of text: 48656c6c6f2c20576f726c6421
> Base64 of hex of text: NDg2NTZjNmM2ZjJjMjA1NzZmNzI2YzY0MjE=
```

## Useage - Decoding

To decode Base64 to hex then to text, execute `decode.py`

The following prompt will show up

```bash
python decode.py
> Enter Base64 to convert: 
```

Enter the Base64 text to be converted into the prompt and press enter

A list of output in the terminal will be shown

```bash
python decode.py
> Enter Base64 to convert: NDg2NTZjNmM2ZjJjMjA1NzZmNzI2YzY0MjE=
> Using Base: NDg2NTZjNmM2ZjJjMjA1NzZmNzI2YzY0MjE=
> Hex of Base64: 48656c6c6f2c20576f726c6421
> Text of Hex of Base64: Hello, World!
```

When no input is provided. `NDg2NTZjNmM2ZjJjMjA1NzZmNzI2YzY0MjE=` will be used

```bash
python decode.py
> Enter Base64 to convert: 
> Using Base: NDg2NTZjNmM2ZjJjMjA1NzZmNzI2YzY0MjE=
> Hex of Base64: 48656c6c6f2c20576f726c6421
> Text of Hex of Base64: Hello, World!
```

Note if the Base64 entered is not Hex converted to Base64 an error will be raised.

## Functions - encode.py

- Encode Text to Hex

    ```python
    def encode_to_hex(text: str) -> str:
        ''' Converts text to hex using ASCII encoding
        Args: text: str
        Returns: str
        '''
        return text.encode('ASCII').hex()
    ```

- Encode Text to Base64
  
    ```python
    def encode_to_base64(text: str) -> str:
        ''' Converts text to base64 using ASCII encoding
        Args: text: str
        Returns: str
        '''
        return base64.b64encode(text.encode('ASCII')).decode('ASCII')
    ```

## Functions - decode.py

- Decode from Base64
  
    ```python
    def decode_from_base64(text: str) -> str:
        ''' Converts base64 to text using ASCII encoding.    
        Args: text: str
        Returns: str
        '''
        # Accomidate for missing "="
        text += "=" * int(4 - (len(text) % 4))

        return base64.b64decode(text).decode('ASCII')
    ```

- Decode Text from Hex
  
    ```python
    def decode_from_hex(text: str) -> str:
        ''' Converts hex to text using ASCII encoding
        Args: text: str
        Returns: str
        '''
        return bytearray.fromhex(text).decode()
    ```

## Operations - encode.py

Convert Text to something in the following steps:

1. Prompt for text to encode, if not text use `Hello, World!`

    ```python
    text = str(input("Enter text to convert: "))
    if not text:
        text = 'Hello, World!'
    ```

2. Encode as ASCII and convert to hex

    ```python
    text_in_hex = encode_to_hex(text)
    print(f'Hex of text: {text_in_hex}')
    ```

3. Encode the text and convert to base64 string

    ```python
    text_in_hex_in_base64 = encode_to_base64(text_in_hex)
    print(f'Base64 of hex of text: {text_in_hex_in_base64}')
    ```

## Operations - decode.py

1. Prompt for text to decode, if not text use `NDg2NTZjNmM2ZjJjMjA1NzZmNzI2YzY0MjE=`

    ```python
    text = str(input("Enter Base64 to convert: "))
    if not text:
        text = 'NDg2NTZjNmM2ZjJjMjA1NzZmNzI2YzY0MjE='
    ```

2. Decode from Base64 back to Hex

    ```python
    base64_encoded_text = decode_from_base64(text)
    print(f'Hex of Base64: {base64_encoded_text}')
    ```

3. Decode from Hex back to Text String

    ```python
    hex_encoded_text = decode_from_hex(base64_encoded_text)
    print(f'Text of Hex of Base64: {hex_encoded_text}')
    ```
