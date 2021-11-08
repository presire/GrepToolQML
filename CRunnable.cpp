#include <QCryptographicHash>
#include "CRunnable.h"


namespace
{
    QString generateKeyHash( const QString& key, const QString& salt )
    {
        QByteArray data;

        data.append(key.toUtf8());
        data.append(salt.toUtf8());
        data = QCryptographicHash::hash(data, QCryptographicHash::Sha1).toHex();

        return data;
    }
}


CRunnable::CRunnable(const QString& key) : m_key(key), m_memLockKey(generateKeyHash(key, "_memLockKey")),
                                           m_sharedmemKey(generateKeyHash(key, "_sharedmemKey")), m_sharedMem(m_sharedmemKey),
                                           m_memLock(m_memLockKey, 1)
{
    m_memLock.acquire();
    {
        QSharedMemory fix(m_sharedmemKey);    // Fix for *nix: http://habrahabr.ru/post/173281/
        fix.attach();
    }

    m_memLock.release();
}


CRunnable::~CRunnable()
{
    release();
}


bool CRunnable::isAnotherRunning()
{
    if (m_sharedMem.isAttached())
    {
        return false;
    }

    m_memLock.acquire();

    const bool isRunning = m_sharedMem.attach();

    if (isRunning)
    {
        m_sharedMem.detach();
    }

    m_memLock.release();

    return isRunning;
}


bool CRunnable::tryToRun()
{
    // Extra check
    if (isAnotherRunning())
    {
        return false;
    }

    m_memLock.acquire();

    const bool result = m_sharedMem.create(sizeof(quint64));

    m_memLock.release();

    if (!result)
    {
        release();
        return false;
    }

    return true;
}


void CRunnable::release()
{
    m_memLock.acquire();

    if (m_sharedMem.isAttached())
    {
        m_sharedMem.detach();
    }

    m_memLock.release();
}
