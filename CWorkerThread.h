#ifndef CWORKERTHREAD_H
#define CWORKERTHREAD_H

#include <QCoreApplication>
#include <QObject>
#include <QException>
#include <QDirIterator>
#include <QDir>
#include <QFile>
#include <QtConcurrent/qtconcurrentrun.h>
#include <thread>


class CWorkerThread : public QObject
{
    Q_OBJECT

private:
    int                 m_iError;
    std::atomic_bool    m_isCancel;


public:
    void SearchThread(const QString &Path, const QString &Filter, int option);

private:


public:
    explicit CWorkerThread(QObject *parent = nullptr);
    int GetError() const;


public slots:
    void Search(const QString &Path, const QString &Filter, int option);
    void Cancel();


signals:
    void result(int isFile, QString DirName, QString FileName);
    void resultCancel();
    void resultDone(QString strItemCount);
    void processDone();
};

#endif // CWORKERTHREAD_H
