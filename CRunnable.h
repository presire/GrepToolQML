#ifndef CRUNNABLE_H
#define CRUNNABLE_H

#include <QObject>
#include <QSharedMemory>
#include <QSystemSemaphore>


class CRunnable
{
private:
    QString generateKeyHash(const QString& key, const QString& salt);


public:
    CRunnable(const QString& key);
    ~CRunnable();

    bool isAnotherRunning();
    bool tryToRun();
    void release();


private:
    const QString m_key;
    const QString m_memLockKey;
    const QString m_sharedmemKey;

    QSharedMemory m_sharedMem;
    QSystemSemaphore m_memLock;

    Q_DISABLE_COPY(CRunnable)
};

#endif // CRUNNABLE_H
