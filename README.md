# MD5 in Elixir

This is a implementation of the MD5 algorithm written in pure Elixir. The code was written as a learning exercise following the MD5 specification found [here](https://tools.ietf.org/html/rfc1321).

## Usage

Load the code in the Elixir REPL:

```bash
iex -S Mix
```

To calculate the MD5 hash:

```elixir
iex(1)> Md5.digest("Hello world")
"3e25960a79dbc69b674cd4ec67a72c62"
```

To calculate the checksum of a file:

```elixir
iex(1)> Md5.digest_file("./README.md")
"8b1d50c6e91ca212a8af9bab047de574"
```
