defmodule Md5 do
  @moduledoc """
  Documentation for Md5.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Md5.digest("Hello world")
      "3e25960a79dbc69b674cd4ec67a72c62"

  """

  # Import module to perform bitwise operations
  use Bitwise

  # Pre-determined constants to shift bits - aproximated to give biggest avalanche
  @shift_constants {
      7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,
      5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,
      4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,
      6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21,
  }

  # Some more constants
  def calc_constant(i) do
    trunc(:math.pow(2, 32) * abs(:math.sin(i + 1))) &&& 0xFFFFFFFF
  end

  # Perform digest on message and return MD5 hex checksum
  def digest(message) do
    x = hash(message)
    Base.encode16(<<x::little-unsigned-size(128)>>, case: :lower)
  end

  # Perform digest on file contents
  def digest_file(filepath) do
    digest(File.read!(filepath))
  end

  # Generate bit hash
  def hash(message) do
    {a, b, c, d} = {0x67452301, 0xEFCDAB89, 0x98BADCFE, 0x10325476}

    padded_message = pad(message)
    process_message(padded_message, a, b, c, d)
  end

  # Base case - when no more message to process
  def process_message(message, a, b, c, d) when bit_size(message) == 0 do
    # Bit shift to put 128 bits together
    a + (b <<< 32) + (c <<< 64) + (d <<< 96)
  end

  # Processing the 512 bits of the message
  def process_message(message, a, b, c, d) do
    # Use pattern matching to grab first 512 bits of message
    <<chunk::bitstring-size(512), remaining::bitstring>> = message

    # Calculate new values for hash segments
    {a_new, b_new, c_new, d_new} = step(0, chunk, a, b, c, d)

    # Add new segments to old segments and process rest of message
    # Use bitwise 'AND' to mask anything more than 32 bits and "emulate" an overflow
    process_message(
      remaining,
      a_new + a &&& 0xFFFFFFFF,
      b_new + b &&& 0xFFFFFFFF,
      c_new + c &&& 0xFFFFFFFF,
      d_new + d &&& 0xFFFFFFFF
    )
  end

  def index_func(i, x, y, z) when i < 16 do
    {(x &&& y) ||| (~~~x &&& z), i}
  end

  def index_func(i, x, y, z) when i < 32 do
    {(x &&& z) ||| (y &&& ~~~z), rem(5 * i + 1, 16)}
  end

  def index_func(i, x, y, z) when i < 48 do
    {x ^^^ y ^^^ z, rem(3 * i + 5, 16)}
  end

  def index_func(i, x, y, z) when i < 64 do
    {y ^^^ (x ||| ~~~z), rem(7 * i, 16)}
  end

  # Base case - return when i reaches 64
  def step(i, _, a, b, c, d) when i >= 64, do: {a, b, c, d}

  # Each
  def step(i, m, a, b, c, d) when i >= 0 do
    # Get constants and perform bitwise operations
    t = calc_constant(i)
    {f, g} = index_func(i, b, c, d)

    # Get 32 bit part of message for rotation
    start_pos = g * 32
    <<_::size(start_pos), chunk::little-size(32), _::bitstring>> = m

    # Where A influences the algorithm and rotation
    to_rotate = a + f + chunk + t
    b_new = b + leftrotate(to_rotate, elem(@shift_constants, i)) &&& 0xFFFFFFFF

    # Next step A -> D, B -> New B, C -> B, D -> C
    step(i + 1, m, d, b_new, b, c)
  end

  # Produced padded message according to MD5 specification
  def pad(message) do
    bits = bit_size(message)
    # Remaining bits to make up to 512
    r_bits = 512 - rem(bits, 512)

    # Bits to add - add 512 extra if not enough remain to add message size + 1
    p_bits =
      if r_bits < 65 do
        r_bits + 512
      else
        r_bits
      end

    # Number of zero bits to add
    z_bits = p_bits - 65

    # Message + 1 + (..000..)? + size of message
    <<message::binary, 1::little-size(1), 0::little-size(z_bits), bits::little-size(64)>>
  end

  def leftrotate(b, shift) do
    b_ = b &&& 0xFFFFFFFF
    (b_ <<< shift ||| b_ >>> (32 - shift)) &&& 0xFFFFFFFF
  end
end

