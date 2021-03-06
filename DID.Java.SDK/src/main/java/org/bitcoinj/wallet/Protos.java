// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: wallet.proto

package org.bitcoinj.wallet;

import org.bitcoinj.core.ByteString;

public final class Protos {
  private Protos() {}

  public interface ScryptParametersOrBuilder {

    /**
     * <pre>
     * Salt to use in generation of the wallet password (8 bytes)
     * </pre>
     *
     * <code>required bytes salt = 1;</code>
     */
    boolean hasSalt();
    /**
     * <pre>
     * Salt to use in generation of the wallet password (8 bytes)
     * </pre>
     *
     * <code>required bytes salt = 1;</code>
     */
    ByteString getSalt();

    /**
     * <pre>
     * CPU/ memory cost parameter
     * </pre>
     *
     * <code>optional int64 n = 2 [default = 16384];</code>
     */
    boolean hasN();
    /**
     * <pre>
     * CPU/ memory cost parameter
     * </pre>
     *
     * <code>optional int64 n = 2 [default = 16384];</code>
     */
    long getN();

    /**
     * <pre>
     * Block size parameter
     * </pre>
     *
     * <code>optional int32 r = 3 [default = 8];</code>
     */
    boolean hasR();
    /**
     * <pre>
     * Block size parameter
     * </pre>
     *
     * <code>optional int32 r = 3 [default = 8];</code>
     */
    int getR();

    /**
     * <pre>
     * Parallelisation parameter
     * </pre>
     *
     * <code>optional int32 p = 4 [default = 1];</code>
     */
    boolean hasP();
    /**
     * <pre>
     * Parallelisation parameter
     * </pre>
     *
     * <code>optional int32 p = 4 [default = 1];</code>
     */
    int getP();
  }
  /**
   * <pre>
   ** The parameters used in the scrypt key derivation function.
   *  The default values are taken from http://www.tarsnap.com/scrypt/scrypt-slides.pdf.
   *  They can be increased - n is the number of iterations performed and
   *  r and p can be used to tweak the algorithm - see:
   *  http://stackoverflow.com/questions/11126315/what-are-optimal-scrypt-work-factors
   * </pre>
   *
   * Protobuf type {@code wallet.ScryptParameters}
   */
  public  static final class ScryptParameters implements
      // @@protoc_insertion_point(message_implements:wallet.ScryptParameters)
      ScryptParametersOrBuilder {
	private ScryptParameters(ScryptParametersOrBuilder builder) {
	  //super(builder);
	}
	private ScryptParameters() {
      salt_ = ByteString.EMPTY;
      n_ = 16384L;
      r_ = 8;
      p_ = 1;
    }

    private int bitField0_;
    public static final int SALT_FIELD_NUMBER = 1;
    private ByteString salt_;
    /**
     * <pre>
     * Salt to use in generation of the wallet password (8 bytes)
     * </pre>
     *
     * <code>required bytes salt = 1;</code>
     */
    @Override
	public boolean hasSalt() {
      return ((bitField0_ & 0x00000001) != 0);
    }
    /**
     * <pre>
     * Salt to use in generation of the wallet password (8 bytes)
     * </pre>
     *
     * <code>required bytes salt = 1;</code>
     */
    @Override
	public ByteString getSalt() {
      return salt_;
    }

    public static final int N_FIELD_NUMBER = 2;
    private long n_;
    /**
     * <pre>
     * CPU/ memory cost parameter
     * </pre>
     *
     * <code>optional int64 n = 2 [default = 16384];</code>
     */
    @Override
	public boolean hasN() {
      return ((bitField0_ & 0x00000002) != 0);
    }
    /**
     * <pre>
     * CPU/ memory cost parameter
     * </pre>
     *
     * <code>optional int64 n = 2 [default = 16384];</code>
     */
    @Override
	public long getN() {
      return n_;
    }

    public static final int R_FIELD_NUMBER = 3;
    private int r_;
    /**
     * <pre>
     * Block size parameter
     * </pre>
     *
     * <code>optional int32 r = 3 [default = 8];</code>
     */
    @Override
	public boolean hasR() {
      return ((bitField0_ & 0x00000004) != 0);
    }
    /**
     * <pre>
     * Block size parameter
     * </pre>
     *
     * <code>optional int32 r = 3 [default = 8];</code>
     */
    @Override
	public int getR() {
      return r_;
    }

    public static final int P_FIELD_NUMBER = 4;
    private int p_;
    /**
     * <pre>
     * Parallelisation parameter
     * </pre>
     *
     * <code>optional int32 p = 4 [default = 1];</code>
     */
    @Override
	public boolean hasP() {
      return ((bitField0_ & 0x00000008) != 0);
    }
    /**
     * <pre>
     * Parallelisation parameter
     * </pre>
     *
     * <code>optional int32 p = 4 [default = 1];</code>
     */
    @Override
	public int getP() {
      return p_;
    }

    private byte memoizedIsInitialized = -1;
    private int memoizedHashCode = 0;

    public final boolean isInitialized() {
      byte isInitialized = memoizedIsInitialized;
      if (isInitialized == 1) return true;
      if (isInitialized == 0) return false;

      if (!hasSalt()) {
        memoizedIsInitialized = 0;
        return false;
      }
      memoizedIsInitialized = 1;
      return true;
    }

    @java.lang.Override
    public boolean equals(final java.lang.Object obj) {
      if (obj == this) {
       return true;
      }
      if (!(obj instanceof org.bitcoinj.wallet.Protos.ScryptParameters)) {
        return super.equals(obj);
      }
      org.bitcoinj.wallet.Protos.ScryptParameters other = (org.bitcoinj.wallet.Protos.ScryptParameters) obj;

      if (hasSalt() != other.hasSalt()) return false;
      if (hasSalt()) {
        if (!getSalt()
            .equals(other.getSalt())) return false;
      }
      if (hasN() != other.hasN()) return false;
      if (hasN()) {
        if (getN()
            != other.getN()) return false;
      }
      if (hasR() != other.hasR()) return false;
      if (hasR()) {
        if (getR()
            != other.getR()) return false;
      }
      if (hasP() != other.hasP()) return false;
      if (hasP()) {
        if (getP()
            != other.getP()) return false;
      }
      return true;
    }

    private static int hashLong(long n) {
      return (int) (n ^ (n >>> 32));
    }

    @java.lang.Override
    public int hashCode() {
      if (memoizedHashCode != 0) {
        return memoizedHashCode;
      }
      int hash = 41;
      if (hasSalt()) {
        hash = (37 * hash) + SALT_FIELD_NUMBER;
        hash = (53 * hash) + getSalt().hashCode();
      }
      if (hasN()) {
        hash = (37 * hash) + N_FIELD_NUMBER;
        hash = (53 * hash) + hashLong(getN());
      }
      if (hasR()) {
        hash = (37 * hash) + R_FIELD_NUMBER;
        hash = (53 * hash) + getR();
      }
      if (hasP()) {
        hash = (37 * hash) + P_FIELD_NUMBER;
        hash = (53 * hash) + getP();
      }
      memoizedHashCode = hash;
      return hash;
    }


    public Builder newBuilderForType() { return newBuilder(); }
    public static Builder newBuilder() {
      return DEFAULT_INSTANCE.toBuilder();
    }

    public static Builder newBuilder(org.bitcoinj.wallet.Protos.ScryptParameters prototype) {
      return DEFAULT_INSTANCE.toBuilder().mergeFrom(prototype);
    }

    public Builder toBuilder() {
      return this == DEFAULT_INSTANCE
          ? new Builder() : new Builder().mergeFrom(this);
    }

    /**
     * <pre>
     ** The parameters used in the scrypt key derivation function.
     *  The default values are taken from http://www.tarsnap.com/scrypt/scrypt-slides.pdf.
     *  They can be increased - n is the number of iterations performed and
     *  r and p can be used to tweak the algorithm - see:
     *  http://stackoverflow.com/questions/11126315/what-are-optimal-scrypt-work-factors
     * </pre>
     *
     * Protobuf type {@code wallet.ScryptParameters}
     */
    public static final class Builder implements
        // @@protoc_insertion_point(builder_implements:wallet.ScryptParameters)
        org.bitcoinj.wallet.Protos.ScryptParametersOrBuilder {

      // Construct using org.bitcoinj.wallet.Protos.ScryptParameters.newBuilder()
      private Builder() {
        maybeForceBuilderInitialization();
      }

      private void maybeForceBuilderInitialization() {
      }

      public org.bitcoinj.wallet.Protos.ScryptParameters build() {
          org.bitcoinj.wallet.Protos.ScryptParameters result = buildPartial();
          if (!result.isInitialized()) {
            throw new IllegalStateException(result.toString());
          }
          return result;
        }

        public org.bitcoinj.wallet.Protos.ScryptParameters buildPartial() {
          org.bitcoinj.wallet.Protos.ScryptParameters result = new org.bitcoinj.wallet.Protos.ScryptParameters(this);
          int from_bitField0_ = bitField0_;
          int to_bitField0_ = 0;
          if (((from_bitField0_ & 0x00000001) == 0x00000001)) {
            to_bitField0_ |= 0x00000001;
          }
          result.salt_ = salt_;
          if (((from_bitField0_ & 0x00000002) == 0x00000002)) {
            to_bitField0_ |= 0x00000002;
          }
          result.n_ = n_;
          if (((from_bitField0_ & 0x00000004) == 0x00000004)) {
            to_bitField0_ |= 0x00000004;
          }
          result.r_ = r_;
          if (((from_bitField0_ & 0x00000008) == 0x00000008)) {
            to_bitField0_ |= 0x00000008;
          }
          result.p_ = p_;
          result.bitField0_ = to_bitField0_;

          return result;
        }


      public Builder clear() {
        salt_ = ByteString.EMPTY;
        bitField0_ = (bitField0_ & ~0x00000001);
        n_ = 16384L;
        bitField0_ = (bitField0_ & ~0x00000002);
        r_ = 8;
        bitField0_ = (bitField0_ & ~0x00000004);
        p_ = 1;
        bitField0_ = (bitField0_ & ~0x00000008);
        return this;
      }

      public Builder mergeFrom(org.bitcoinj.wallet.Protos.ScryptParameters other) {
        if (other == org.bitcoinj.wallet.Protos.ScryptParameters.getDefaultInstance()) return this;
        if (other.hasSalt()) {
          setSalt(other.getSalt());
        }
        if (other.hasN()) {
          setN(other.getN());
        }
        if (other.hasR()) {
          setR(other.getR());
        }
        if (other.hasP()) {
          setP(other.getP());
        }
        return this;
      }

      public final boolean isInitialized() {
        if (!hasSalt()) {
          return false;
        }
        return true;
      }

      private int bitField0_;

      private ByteString salt_ = ByteString.EMPTY;
      /**
       * <pre>
       * Salt to use in generation of the wallet password (8 bytes)
       * </pre>
       *
       * <code>required bytes salt = 1;</code>
       */
      @Override
	public boolean hasSalt() {
        return ((bitField0_ & 0x00000001) != 0);
      }
      /**
       * <pre>
       * Salt to use in generation of the wallet password (8 bytes)
       * </pre>
       *
       * <code>required bytes salt = 1;</code>
       */
      @Override
	public ByteString getSalt() {
        return salt_;
      }
      /**
       * <pre>
       * Salt to use in generation of the wallet password (8 bytes)
       * </pre>
       *
       * <code>required bytes salt = 1;</code>
       */
      public Builder setSalt(ByteString value) {
        if (value == null) {
    throw new NullPointerException();
  }
  bitField0_ |= 0x00000001;
        salt_ = value;
        return this;
      }
      /**
       * <pre>
       * Salt to use in generation of the wallet password (8 bytes)
       * </pre>
       *
       * <code>required bytes salt = 1;</code>
       */
      public Builder clearSalt() {
        bitField0_ = (bitField0_ & ~0x00000001);
        salt_ = getDefaultInstance().getSalt();

        return this;
      }

      private long n_ = 16384L;
      /**
       * <pre>
       * CPU/ memory cost parameter
       * </pre>
       *
       * <code>optional int64 n = 2 [default = 16384];</code>
       */
      @Override
	public boolean hasN() {
        return ((bitField0_ & 0x00000002) != 0);
      }
      /**
       * <pre>
       * CPU/ memory cost parameter
       * </pre>
       *
       * <code>optional int64 n = 2 [default = 16384];</code>
       */
      @Override
	public long getN() {
        return n_;
      }
      /**
       * <pre>
       * CPU/ memory cost parameter
       * </pre>
       *
       * <code>optional int64 n = 2 [default = 16384];</code>
       */
      public Builder setN(long value) {
        bitField0_ |= 0x00000002;
        n_ = value;

        return this;
      }
      /**
       * <pre>
       * CPU/ memory cost parameter
       * </pre>
       *
       * <code>optional int64 n = 2 [default = 16384];</code>
       */
      public Builder clearN() {
        bitField0_ = (bitField0_ & ~0x00000002);
        n_ = 16384L;

        return this;
      }

      private int r_ = 8;
      /**
       * <pre>
       * Block size parameter
       * </pre>
       *
       * <code>optional int32 r = 3 [default = 8];</code>
       */
      @Override
	public boolean hasR() {
        return ((bitField0_ & 0x00000004) != 0);
      }
      /**
       * <pre>
       * Block size parameter
       * </pre>
       *
       * <code>optional int32 r = 3 [default = 8];</code>
       */
      @Override
	public int getR() {
        return r_;
      }
      /**
       * <pre>
       * Block size parameter
       * </pre>
       *
       * <code>optional int32 r = 3 [default = 8];</code>
       */
      public Builder setR(int value) {
        bitField0_ |= 0x00000004;
        r_ = value;

        return this;
      }
      /**
       * <pre>
       * Block size parameter
       * </pre>
       *
       * <code>optional int32 r = 3 [default = 8];</code>
       */
      public Builder clearR() {
        bitField0_ = (bitField0_ & ~0x00000004);
        r_ = 8;

        return this;
      }

      private int p_ = 1;
      /**
       * <pre>
       * Parallelisation parameter
       * </pre>
       *
       * <code>optional int32 p = 4 [default = 1];</code>
       */
      @Override
	public boolean hasP() {
        return ((bitField0_ & 0x00000008) != 0);
      }
      /**
       * <pre>
       * Parallelisation parameter
       * </pre>
       *
       * <code>optional int32 p = 4 [default = 1];</code>
       */
      @Override
	public int getP() {
        return p_;
      }
      /**
       * <pre>
       * Parallelisation parameter
       * </pre>
       *
       * <code>optional int32 p = 4 [default = 1];</code>
       */
      public Builder setP(int value) {
        bitField0_ |= 0x00000008;
        p_ = value;

        return this;
      }
      /**
       * <pre>
       * Parallelisation parameter
       * </pre>
       *
       * <code>optional int32 p = 4 [default = 1];</code>
       */
      public Builder clearP() {
        bitField0_ = (bitField0_ & ~0x00000008);
        p_ = 1;

        return this;
      }

      // @@protoc_insertion_point(builder_scope:wallet.ScryptParameters)
    }

    // @@protoc_insertion_point(class_scope:wallet.ScryptParameters)
    private static final org.bitcoinj.wallet.Protos.ScryptParameters DEFAULT_INSTANCE;
    static {
      DEFAULT_INSTANCE = new org.bitcoinj.wallet.Protos.ScryptParameters();
    }

    public static org.bitcoinj.wallet.Protos.ScryptParameters getDefaultInstance() {
      return DEFAULT_INSTANCE;
    }
  }

  /**
   * <pre>
   ** A bitcoin wallet
   * </pre>
   *
   * Protobuf type {@code wallet.Wallet}
   */
  public  static final class Wallet {
    /**
     * <pre>
     **
     * The encryption type of the wallet.
     * The encryption type is UNENCRYPTED for wallets where the wallet does not support encryption - wallets prior to
     * encryption support are grandfathered in as this wallet type.
     * When a wallet is ENCRYPTED_SCRYPT_AES the keys are either encrypted with the wallet password or are unencrypted.
     * </pre>
     *
     * Protobuf enum {@code wallet.Wallet.EncryptionType}
     */
    public enum EncryptionType {
      /**
       * <pre>
       * All keys in the wallet are unencrypted
       * </pre>
       *
       * <code>UNENCRYPTED = 1;</code>
       */
      UNENCRYPTED(1),
      /**
       * <pre>
       * All keys are encrypted with a passphrase based KDF of scrypt and AES encryption
       * </pre>
       *
       * <code>ENCRYPTED_SCRYPT_AES = 2;</code>
       */
      ENCRYPTED_SCRYPT_AES(2),
      ;

      /**
       * <pre>
       * All keys in the wallet are unencrypted
       * </pre>
       *
       * <code>UNENCRYPTED = 1;</code>
       */
      public static final int UNENCRYPTED_VALUE = 1;
      /**
       * <pre>
       * All keys are encrypted with a passphrase based KDF of scrypt and AES encryption
       * </pre>
       *
       * <code>ENCRYPTED_SCRYPT_AES = 2;</code>
       */
      public static final int ENCRYPTED_SCRYPT_AES_VALUE = 2;

      public final int getNumber() {
        return value;
      }

      /**
       * @deprecated Use {@link #forNumber(int)} instead.
       */
      @java.lang.Deprecated
      public static EncryptionType valueOf(int value) {
        return forNumber(value);
      }

      public static EncryptionType forNumber(int value) {
        switch (value) {
          case 1: return UNENCRYPTED;
          case 2: return ENCRYPTED_SCRYPT_AES;
          default: return null;
        }
      }

      private final int value;

      private EncryptionType(int value) {
        this.value = value;
      }

      // @@protoc_insertion_point(enum_scope:wallet.Wallet.EncryptionType)
    }
  }
}
