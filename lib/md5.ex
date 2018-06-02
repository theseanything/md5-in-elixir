defmodule Md5 do
  @moduledoc """
  Provides methods for calculating a MD5 hash. This module implements the MD5 hashing algorithm in pure Elixir.
  """
  use Bitwise

  # Pre-determined constants to shift bits - aproximated to give biggest avalanche
  @shift_constants {
      7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,
      5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,
      4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,
      6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21,
  }

  # Pre-defined initial values of message digest buffer
  @buffer_preset {0x67452301, 0xEFCDAB89, 0x98BADCFE, 0x10325476}

  @doc """
  Used to calculate the constants of the 64-element table defined in the specification.
  """
  def calc_constant(i) do
    overflow(trunc(:math.pow(2, 32) * abs(:math.sin(i + 1))))
  end

  @doc """
  Returns hex representation of a MD5 digest of a message of arbitrary size.
  """
  def digest(message) do
    x = hash(message)
    Base.encode16(<<x::little-unsigned-size(128)>>, case: :lower)
  end

  @doc """
  Returns hex representation of a MD5 digest of a file.
  """
  def digest_file(filepath) do
    digest(File.read!(filepath))
  end

  @doc """
  Returns MD5 hash of a message of arbitrary size.
  """
  def hash(message) do
    {a, b, c, d} = @buffer_preset

    padded_message = pad(message)
    process_message(padded_message, a, b, c, d)
  end

  # Produced padded message according to MD5 specification
  def pad(message) do
    msg_length = bit_size(message)

    num_of_zeros = 512 - rem(msg_length + 65, 512)

    # Message + 1 + (..000..)? + size of message
    <<message::binary, 1::little-size(1), 0::little-size(num_of_zeros), msg_length::little-size(64)>>
  end

  @doc """
  Returns the concatenated message digest when no more message left to process.
  """
  def process_message(message, a, b, c, d) when bit_size(message) == 0 do
    # Bit shift to put 128 bits together
    a + (b <<< 32) + (c <<< 64) + (d <<< 96)
  end

  @doc """
  Computes the state change for the message digest using first 512 bits of a message.
  """
  def process_message(message, a, b, c, d) do
    # Use pattern matching to grab first 512 bits of message
    <<chunk::bitstring-size(512), remaining::bitstring>> = message

    # Calculate new values for hash segments
    {a_new, b_new, c_new, d_new} = step(0, chunk, a, b, c, d)

    # Add new segments to old segments and process rest of message
    process_message(
      remaining,
      overflow(a_new + a),
      overflow(b_new + b),
      overflow(c_new + c),
      overflow(d_new + d)
    )
  end

  @doc """
  Returns the message digest after 64 steps.
  """
  def step(i, _, a, b, c, d) when i >= 64, do: {a, b, c, d}

  @doc """
  Calculates part of the state change for the message digest.
  """
  def step(i, m, a, b, c, d) when i >= 0 do
    # Get constants and perform bitwise operations
    t = calc_constant(i)
    {f, g} = index_func(i, b, c, d)

    # Get 32 bit part of message for rotation
    start_pos = g * 32
    <<_::size(start_pos), chunk::little-size(32), _::bitstring>> = m

    # Where A influences the algorithm and rotation
    to_rotate = a + f + chunk + t
    b_new = overflow(b + leftrotate(to_rotate, elem(@shift_constants, i)))

    # Next step A -> D, B -> New B, C -> B, D -> C
    step(i + 1, m, d, b_new, b, c)
  end

  @doc """
  Round 1
  """
  def index_func(i, x, y, z) when i < 16 do
    {(x &&& y) ||| (~~~x &&& z), i}
  end

  @doc """
  Round 2
  """
  def index_func(i, x, y, z) when i < 32 do
    {(x &&& z) ||| (y &&& ~~~z), rem(5 * i + 1, 16)}
  end

  @doc """
  Round 3
  """
  def index_func(i, x, y, z) when i < 48 do
    {x ^^^ y ^^^ z, rem(3 * i + 5, 16)}
  end

  @doc """
  Round 1
  """
  def index_func(i, x, y, z) when i < 64 do
    {y ^^^ (x ||| ~~~z), rem(7 * i, 16)}
  end

  @doc """
  Performs a bitwise left rotation.
  """
  def leftrotate(b, shift) do
    b_ = overflow(b)
    overflow(b_ <<< shift ||| b_ >>> (32 - shift))
  end

  @doc """
  Emulates at 32 bit overflow on a value.
  """
  def overflow(value) do
    value &&& 0xFFFFFFFF
  end
end

