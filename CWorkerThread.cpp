#include "CWorkerThread.h"

CWorkerThread::CWorkerThread(QObject *parent) : QObject(parent), m_iError(0), m_isCancel(false)
{

}


int CWorkerThread::GetError() const
{
    return m_iError;
}

void CWorkerThread::Search(const QString &Path, const QString &Filter, int option)
{
//    QString strFilePath = QCoreApplication::applicationDirPath() + QDir::separator() + tr("Shutdown.wav");
//    QFuture<void> Task = QtConcurrent::run([=]()
//    {
//        QSoundEffect effect;
//        QEventLoop loop;
//        effect.setSource(QUrl::fromLocalFile(strFilePath));
//        effect.setVolume(50);
//        effect.play();
//        QObject::connect(&effect, &QSoundEffect::playingChanged, [&loop](){loop.exit();});
//        loop.exec();
//    });
//    Task.waitForFinished();

    m_isCancel = false;

    // Check input extension
    QString Extension = Filter;
    if(Filter.isEmpty())
    {   // If extension is empty
        Extension = tr("*");
    }

    QStringList NameFilters = Extension.split(tr(";"));

    QDir::Filters OptionFlag;
    if(option == 0)
    {
        OptionFlag = QDir::Files;
    }
    else if(option == 1)
    {
        OptionFlag = QDir::Files | QDir::Dirs;
    }
    else
    {
        OptionFlag = QDir::Dirs;
    }

    long long int lItemCount = 0;

    QDirIterator itDirs(Path, NameFilters, OptionFlag, QDirIterator::Subdirectories);
    while(itDirs.hasNext())
    {
        if(m_isCancel)
        {
            break;
        }

        QString file = itDirs.next();

        QFileInfo info(file);

        if(info.baseName().isEmpty())
        {
            continue;
        }

        int isFile = 0;
        if(info.isFile())
        {
            isFile = 0;
        }
        else
        {
            isFile = 1;
        }

        QString DirName  = info.absolutePath();   // Ex. DirName  = /usr/bin, info = /usr/bin/cat
        QString FileName = tr("");
        if(!info.suffix().isEmpty())
        {   // If exist suffix
            FileName = info.baseName() + tr(".") + info.suffix();      // Ex. FileName = cat,      info = /usr/bin/cat
        }
        else
        {
            FileName = info.baseName();
        }

        emit result(isFile, DirName, FileName);

        lItemCount++;

        std::this_thread::sleep_for(std::chrono::microseconds(20));
    }

    if(m_isCancel)
    {
        emit resultCancel();
    }
    else
    {
        QString strItemCount = QString::number(lItemCount);
        emit resultDone(strItemCount);
    }

    emit processDone();

    return;
}


void CWorkerThread::Cancel()
{
    m_isCancel = true;
}
