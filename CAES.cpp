#include "CAES.h"

int w[60];                            /* FIPS 197 P.19 5.2 Key Expansion */

CAES::CAES(const char *pstrAES)
{
    QString strAES = pstrAES;

    strAES = strAES.toUpper();
    if(!strAES.compare("AES192"))
    {
        m_NK = 6;
        m_NR = 12;
        m_KeyLength = 24;
    }
    else if(!strAES.compare("AES256"))
    {
        m_NK = 8;
        m_NR = 14;
        m_KeyLength = 32;
    }
    else
    {   // Default AES128
        m_NK = 4;
        m_NR = 10;
        m_KeyLength = 16;
    }

    /* FIPS 197  P.35 Appendix C.1 AES-128 Test */
    memcpy(m_key, m_Keys, m_KeyLength);
}

CAES::~CAES()
{

}

#ifdef QT_DEBUG
// データc[]をターミナルに表示する
void CAES::datadump(const char c[], void *dt, int len)
{
    unsigned char *cdt = (unsigned char *)dt;

    QString Msg = c;
    for(int i = 0; i < len * 4; i++)
    {
        char hex[4] = {};
        sprintf(hex, "%02x", cdt[i]);
        Msg += hex;
    }

    qDebug() << Msg.toStdString().c_str();
}

// Test Execute
int CAES::Test(const QByteArray &ByaryPlainData)
{
    /* FIPS 197  P.38 Appendix C.2 AES-192 Test */
    /* FIPS 197  P.42 Appendix C.3 AES-256 Test */

    // 16Byteに満たないデータをパディング
    QByteArray ByaryPaddingPlainData = ByaryPlainData;
    int PaddingLength = (sizeof(int) * m_NB) - ByaryPlainData.length() % (sizeof(int) * m_NB);
    if(PaddingLength != 0)
    {
        for(int i = 0; i < PaddingLength; i++)
        {
            ByaryPaddingPlainData.append("\x20");
        }
    }

    // 暗号化するための鍵の準備
    KeyExpansion(m_key);

    int LoopCount = ByaryPaddingPlainData.length() / m_NBb;
    for(int i = 0; i < LoopCount; i++)
    {
        char *init = ByaryPaddingPlainData.mid(i * m_NBb, m_NBb).data();

        // NBより4ワード16バイトと定義している
        int data[m_NB] = {};
        memcpy(data, init, m_NBb);

        datadump("PLAINTEXT: ", data, 4);
        datadump("KEY:       ", m_key, m_NK);

        // Encypt
        Cipher(data);

        datadump("暗号化: ", data, 4);

        // Decrypt
        invCipher(data);

        datadump("復号: ", data, 4);
    }

    return 0;
}

/* FIPS 197  P.15 Figure 5 */
// 暗号化
int CAES::Cipher(int data[])
{
    int i;

    AddRoundKey(data, 0);

    for(i = 1; i < m_NR; i++)
    {
        SubBytes(data);
        ShiftRows(data);
        MixColumns(data);
        AddRoundKey(data, i);
    }

    SubBytes(data);
    ShiftRows(data);
    AddRoundKey(data, i);

    return i;
}

/* FIPS 197  P.21 Figure 12 */
// 復号
int CAES::invCipher(int data[])
{
    AddRoundKey(data, m_NR);

    for(int i = m_NR - 1; i > 0; i--)
    {
        invShiftRows(data);
        invSubBytes(data);
        AddRoundKey(data, i);
        invMixColumns(data, i);
    }

    invShiftRows(data);
    invSubBytes(data);
    AddRoundKey(data, 0);

    return m_NR;
}
#endif

/* FIPS 197  P.15 Figure 5 */ //暗号化
QByteArray CAES::Crypt(const QByteArray &ByaryPlainData)
{
    // 16byteに満たないデータを半角スペース(0x20)でパディング
    QByteArray ByaryPaddingPlainData = ByaryPlainData;
    int PaddingLength = (sizeof(int) * m_NB) - ByaryPlainData.length() % (sizeof(int) * m_NB);
    if(PaddingLength != 0)
    {
        for(int i = 0; i < PaddingLength; i++)
        {
            ByaryPaddingPlainData.append("\x20");
        }
    }

    // 暗号化するための鍵の準備
    KeyExpansion(m_key);

    // 暗号化データ
    QByteArray ByAryEncryptData = {};

    int LoopCount = ByaryPaddingPlainData.length() / m_NBb;
    for(int i = 0; i < LoopCount; i++)
    {
        char *init = ByaryPaddingPlainData.mid(i * m_NBb, m_NBb).data();

        // NBより4ワード16バイトと定義している
        int data[m_NB] = {};
        memcpy(data, init, m_NBb);

        AddRoundKey(data,0);

        int j;
        for(j = 1; j < m_NR; j++)
        {
            SubBytes(data);
            ShiftRows(data);
            MixColumns(data);
            AddRoundKey(data, j);
        }

        SubBytes(data);
        ShiftRows(data);
        AddRoundKey(data, j);

        char hoge[m_NBb] = {};
        memcpy(hoge, data, m_NBb);
        for(int k = 0; k < m_NBb; k++)
        {
            ByAryEncryptData.push_back(hoge[k]);
        }
    }

    return ByAryEncryptData;
}

/* FIPS 197  P.21 Figure 12 */
// 復号
QByteArray CAES::DeCrypt(const QByteArray &ByAryEncryptData)
{
    // 暗号化するための鍵の準備
    KeyExpansion(m_key);

    // 復号データ
    QByteArray ByAryDecryptData = {};

    int LoopCount = ByAryEncryptData.length() / m_NBb;
    for(int i = 0; i < LoopCount; i++)
    {
        char *init = ByAryEncryptData.mid(i * m_NBb, m_NBb).data();

        // NBより4ワード16バイトと定義している
        int data[m_NB] = {};
        memcpy(data, init, m_NBb);

        AddRoundKey(data, m_NR);

        for(int j = m_NR - 1; j > 0; j--)
        {
            invShiftRows(data);
            invSubBytes(data);
            AddRoundKey(data, j);
            invMixColumns(data, j);
        }

        invShiftRows(data);
        invSubBytes(data);
        AddRoundKey(data, 0);

        char hoge[m_NBb] = {};
        memcpy(hoge, data, m_NBb);
        for(int k = 0; k < m_NBb; k++)
        {
            ByAryDecryptData.push_back(hoge[k]);
        }
    }

    return ByAryDecryptData;
}

/* FIPS 197  P.16 Figure 6 */
void CAES::SubBytes(int data[])
{
    int i,j;
    unsigned char *cb=(unsigned char*)data;
    for(i=0;i<m_NBb;i+=4)//理論的な意味から二重ループにしているが意味は無い
    {
        for(j=0;j<4;j++)
        {
            cb[i+j] = Sbox[cb[i+j]];
        }
    }
}

/* FIPS 197  P.22 5.3.2 */
void CAES::invSubBytes(int data[])
{
    int i,j;
    unsigned char *cb=(unsigned char*)data;
    for(i=0;i<m_NBb;i+=4)//理論的な意味から二重ループにしているが意味は無い
    {
        for(j=0;j<4;j++)
        {
            cb[i+j] = invSbox[cb[i+j]];
        }
    }
}

/* FIPS 197  P.17 Figure 8 */
void CAES::ShiftRows(int data[])
{
    int i,j,i4;
    unsigned char *cb=(unsigned char*)data;
    unsigned char cw[m_NBb];
    memcpy(cw,cb,sizeof(cw));
    for(i=0;i< m_NB;i+=4)
    {
        i4 = i*4;
        for(j=1;j<4;j++)
        {
            cw[i4+j+0*4] = cb[i4+j+((j+0)&3)*4];
            cw[i4+j+1*4] = cb[i4+j+((j+1)&3)*4];
            cw[i4+j+2*4] = cb[i4+j+((j+2)&3)*4];
            cw[i4+j+3*4] = cb[i4+j+((j+3)&3)*4];
        }
    }
    memcpy(cb,cw,sizeof(cw));
}

/* FIPS 197  P.22 Figure 13 */
void CAES::invShiftRows(int data[])
{
    int i,j,i4;
    unsigned char *cb=(unsigned char*)data;
    unsigned char cw[m_NBb];
    memcpy(cw,cb,sizeof(cw));
    for(i=0;i<m_NB;i+=4)
    {
        i4 = i*4;
        for(j=1;j<4;j++)
        {
            cw[i4+j+((j+0)&3)*4] = cb[i4+j+0*4];
            cw[i4+j+((j+1)&3)*4] = cb[i4+j+1*4];
            cw[i4+j+((j+2)&3)*4] = cb[i4+j+2*4];
            cw[i4+j+((j+3)&3)*4] = cb[i4+j+3*4];
        }
    }
    memcpy(cb,cw,sizeof(cw));
}

/* FIPS 197 P.10 4.2 乗算 (n倍) */
int CAES::mul(int dt,int n)
{
    int i,x=0;
    for(i=8;i>0;i>>=1)
    {
        x <<= 1;
        if(x&0x100)
            x = (x ^ 0x1b) & 0xff;
        if((n & i))
            x ^= dt;
    }
    return(x);
}

int CAES::dataget(void* data, int n)
{
    return ((unsigned char*)data)[n];
}

/* FIPS 197  P.18 Figure 9 */
void CAES::MixColumns(int data[])
{
    int i4 = 0,
        x  = 0;

    for(int i = 0; i < m_NB; i++)
    {
        i4 = i * 4;
        x  =  mul(dataget(data,i4+0),2) ^
                mul(dataget(data,i4+1),3) ^
                mul(dataget(data,i4+2),1) ^
                mul(dataget(data,i4+3),1);
        x |= (mul(dataget(data,i4+1),2) ^
              mul(dataget(data,i4+2),3) ^
              mul(dataget(data,i4+3),1) ^
              mul(dataget(data,i4+0),1)) << 8;
        x |= (mul(dataget(data,i4+2),2) ^
              mul(dataget(data,i4+3),3) ^
              mul(dataget(data,i4+0),1) ^
              mul(dataget(data,i4+1),1)) << 16;
        x |= (mul(dataget(data,i4+3),2) ^
              mul(dataget(data,i4+0),3) ^
              mul(dataget(data,i4+1),1) ^
              mul(dataget(data,i4+2),1)) << 24;
        data[i] = x;
    }
}

/* FIPS 197  P.23 5.3.3 */
void CAES::invMixColumns(int data[], [[maybe_unused]] int n)
{
    int i4 = 0,
        x  = 0;

    for(int i=0;i<m_NB;i++)
    {
        i4 = i * 4;
        x  =  mul(dataget(data,i4+0),14) ^
                mul(dataget(data,i4+1),11) ^
                mul(dataget(data,i4+2),13) ^
                mul(dataget(data,i4+3), 9);
        x |= (mul(dataget(data,i4+1),14) ^
              mul(dataget(data,i4+2),11) ^
              mul(dataget(data,i4+3),13) ^
              mul(dataget(data,i4+0), 9)) << 8;
        x |= (mul(dataget(data,i4+2),14) ^
              mul(dataget(data,i4+3),11) ^
              mul(dataget(data,i4+0),13) ^
              mul(dataget(data,i4+1), 9)) << 16;
        x |= (mul(dataget(data,i4+3),14) ^
              mul(dataget(data,i4+0),11) ^
              mul(dataget(data,i4+1),13) ^
              mul(dataget(data,i4+2), 9)) << 24;
        data[i] = x;
    }
}

/* FIPS 197  P.19 Figure 10 */
void CAES::AddRoundKey(int data[], int n)
{
    for(int i = 0; i < m_NB; i++)
    {
        data[i] ^= w[i + m_NB * n];
    }
}

/* FIPS 197  P.20 Figure 11 */ /* FIPS 197  P.19  5.2 */
int CAES::SubWord(int in)
{
    int inw = in;
    unsigned char *cin = (unsigned char*)&inw;
    cin[0] = Sbox[cin[0]];
    cin[1] = Sbox[cin[1]];
    cin[2] = Sbox[cin[2]];
    cin[3] = Sbox[cin[3]];
    return(inw);
}

/* FIPS 197  P.20 Figure 11 */ /* FIPS 197  P.19  5.2 */
int CAES::RotWord(int in)
{
    int inw  = in,
        inw2 = 0;
    unsigned char *cin  = (unsigned char*)&inw;
    unsigned char *cin2 = (unsigned char*)&inw2;
    cin2[0] = cin[1];
    cin2[1] = cin[2];
    cin2[2] = cin[3];
    cin2[3] = cin[0];

    return(inw2);
}

/* FIPS 197  P.20 Figure 11 */
void CAES::KeyExpansion(void *key)
{
    /* FIPS 197  P.27 Appendix A.1 Rcon[i / Nk] */
    // またはmulを使用する
    int Rcon[10] = {0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1b, 0x36};
    int temp;

    memcpy(w, key, m_NK * 4);
    for(int i = m_NK; i < m_NB * (m_NR + 1); i++)
    {
        temp = w[i - 1];
        if((i % m_NK) == 0)
            temp = SubWord(RotWord(temp)) ^ Rcon[(i/m_NK)-1];
        else if(m_NK > 6 && (i%m_NK) == 4)
            temp = SubWord(temp);
        w[i] = w[i-m_NK] ^ temp;
    }
}
