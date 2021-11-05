#include "CMainWindow.h"

CMainWindow::CMainWindow(QObject *parent) : QObject(parent)
{
    m_strIniFilePath = QCoreApplication::applicationDirPath() + QDir::separator() + tr("settings.ini");

    m_UserName = qgetenv("USER");
    m_HomePath = QStandardPaths::standardLocations(QStandardPaths::HomeLocation);

    connect(this, &CMainWindow::startSignal, this, &CMainWindow::startSlot);
    connect(this, &CMainWindow::cancelSignal, this, &CMainWindow::cancelSlot);

//    m_pWorker = std::make_unique<CWorkerThread>();
//    m_pThread = std::make_unique<QThread>();

//    m_pWorker->moveToThread(m_pThread.get());

//    connect(this, &CMainWindow::startSignal, m_pWorker.get(), &CWorkerThread::Search);
//    connect(this, &CMainWindow::cancelSignal, m_pWorker.get(), &CWorkerThread::Cancel);

//    connect(m_pWorker.get(), &CWorkerThread::result, this, &CMainWindow::result);
//    connect(m_pWorker.get(), &CWorkerThread::resultCancel, this, &CMainWindow::resultCancel);
//    connect(m_pWorker.get(), &CWorkerThread::resultDone, this, &CMainWindow::resultDone);

//    m_pThread->start();
}


CMainWindow::~CMainWindow()
{

}

int CMainWindow::getMainWindowX()
{
    QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

    settings.beginGroup("MainWindow");

    int iMainWindowX = 0;
    if(settings.contains("X"))
    {
        iMainWindowX = settings.value("X").toInt();
    }

    settings.endGroup();

    return iMainWindowX;
}

int CMainWindow::getMainWindowY()
{
    QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

    settings.beginGroup("MainWindow");

    int iMainWindowY = 0;
    if(settings.contains("Y"))
    {
        iMainWindowY = settings.value("Y").toInt();
    }

    settings.endGroup();

    return iMainWindowY;
}

int CMainWindow::getMainWindowWidth()
{
    QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

    settings.beginGroup("MainWindow");

#ifdef PINEPHONE
    int iMainWindowWidth = 720;
#else
    int iMainWindowWidth = 1280;
#endif

    if(settings.contains("Width"))
    {
        iMainWindowWidth = settings.value("Width").toInt();
    }

    settings.endGroup();

    return iMainWindowWidth;
}

int CMainWindow::getMainWindowHeight()
{
    QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

    settings.beginGroup("MainWindow");

#ifdef PINEPHONE
    int iMainWindowHeight = 1440;
#else
    int iMainWindowHeight = 960;
#endif

    if(settings.contains("Height"))
    {
        iMainWindowHeight = settings.value("Height").toInt();
    }

    settings.endGroup();

    return iMainWindowHeight;
}

bool CMainWindow::getMainWindowMaximized()
{
    QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

    settings.beginGroup("MainWindow");

    int bMainWindowMaximized = false;
    if(settings.contains("Maximized"))
    {
        bMainWindowMaximized = settings.value("Maximized").toBool();
    }

    settings.endGroup();

    return bMainWindowMaximized;
}

int CMainWindow::setMainWindowState(int X, int Y, int Width, int Height, bool Maximized)
{
    int iRet = 0;

    try
    {
        QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

        settings.beginGroup("MainWindow");
        settings.setValue("X", X);
        settings.setValue("Y", Y);
        settings.setValue("Width", Width);
        settings.setValue("Height", Height);
        if(Maximized)
        {
            settings.setValue("Maximized", "true");
        }
        else
        {
            settings.setValue("Maximized", "false");
        }

        settings.endGroup();
    }
    catch (QException *ex)
    {
        iRet = -1;
    }

    return iRet;
}


bool CMainWindow::getColorMode()
{
    QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

    settings.beginGroup("MainWindow");

    bool bDarkMode = false;
    if(settings.contains("DarkMode"))
    {
        bDarkMode = settings.value("DarkMode").toBool();
    }

    settings.endGroup();

    return bDarkMode;
}


int CMainWindow::setColorMode(bool bDarkMode)
{
    int iRet = 0;

    try
    {
        QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

        settings.beginGroup("MainWindow");

        if(bDarkMode)
        {
            settings.setValue("DarkMode", "true");
        }
        else
        {
            settings.setValue("DarkMode", "false");
        }

        settings.endGroup();
    }
    catch (QException *ex)
    {
        iRet = -1;
    }

    return iRet;
}


int CMainWindow::savePassword(QString strPassword)
{
    if(strPassword.isEmpty())
    {
        return 0;
    }

    QString strFilePath = QCoreApplication::applicationDirPath() + QDir::separator() + tr("Password.txt");

    try
    {
        // Encrypt Password
        CAES AES("");
        QByteArray ByAryEncriptData = AES.Crypt(strPassword.toUtf8());

        QFile File(strFilePath);
        File.open(QIODevice::WriteOnly);

        // If Password File exist, File Data truncate.
        if(File.exists())
        {
            File.resize(strFilePath, 0);
        }

        // Write Data to File
        File.write(ByAryEncriptData);

        // File Close
        File.close();
    }
    catch(QException *e)
    {
        return -1;
    }

    return 0;
}


QString CMainWindow::getPassword()
{
    QString strFilePath = QCoreApplication::applicationDirPath() + QDir::separator() /*strExecutePath*/ + tr("Password.txt");
    QString strPassword = tr("");

    QFile File(strFilePath);
    if(!File.exists())
    {
        // Create Empty Password File
        try
        {
            File.open(QIODevice::WriteOnly);

            File.write(nullptr);

            File.close();
        }
        catch(QException *e)
        {
            return QString(e->what());
        }

        return tr("");
    }
    else
    {
        try
        {
            File.open(QIODevice::ReadOnly);

            QByteArray ByAryEncryptPassword = File.readLine();

            // Decrypt Password
            CAES AES("");
            QByteArray ByAryDecryptData = AES.DeCrypt(ByAryEncryptPassword);

            strPassword = ByAryDecryptData.toStdString().c_str();
            strPassword = strPassword.replace(" ", "", Qt::CaseSensitive);

            File.close();
        }
        catch(QException *e)
        {

        }
    }

    return strPassword;
}


QString CMainWindow::getDirectory()
{
    QString strEditorPath = tr("");

    QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

    settings.beginGroup("MainWindow");

    if(settings.contains("Directory"))
    {
        strEditorPath = settings.value("Directory").toString();
    }

    settings.endGroup();

    return strEditorPath;
}


int CMainWindow::saveDirectory(QString strDirectoryPath)
{
    int iRet = 0;

    try
    {
        QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

        settings.beginGroup("MainWindow");

        settings.setValue("Directory", strDirectoryPath);

        settings.endGroup();
    }
    catch (QException *ex)
    {
        iRet = -1;
    }

    return iRet;
}


QString CMainWindow::getExtension()
{
    QString strEditorPath = tr("");

    QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

    settings.beginGroup("MainWindow");

    if(settings.contains("Extension"))
    {
        strEditorPath = settings.value("Extension").toString();
    }

    settings.endGroup();

    return strEditorPath;
}


int CMainWindow::saveExtension(QString strExtension)
{
    int iRet = 0;

    try
    {
        QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

        settings.beginGroup("MainWindow");

        settings.setValue("Extension", strExtension);

        settings.endGroup();
    }
    catch (QException *ex)
    {
        iRet = -1;
    }

    return iRet;
}


QString CMainWindow::getEditor()
{
    QString strEditorPath = tr("");

    QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

    settings.beginGroup("MainWindow");

    if(settings.contains("Editor"))
    {
        strEditorPath = settings.value("Editor").toString();
    }

    settings.endGroup();

    return strEditorPath;
}


int CMainWindow::saveEditor(QString strEditorPath)
{
    int iRet = 0;

    try
    {
        QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

        settings.beginGroup("MainWindow");

        settings.setValue("Editor", strEditorPath);

        settings.endGroup();
    }
    catch (QException *ex)
    {
        iRet = -1;
    }

    return iRet;
}


QString CMainWindow::getEditorOption()
{
    QString strEditorPath = tr("");

    QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

    settings.beginGroup("MainWindow");

    if(settings.contains("EditorOption"))
    {
        strEditorPath = settings.value("EditorOption").toString();
    }

    settings.endGroup();

    return strEditorPath;
}


int CMainWindow::saveEditorOption(QString strEditorOptionPath)
{
    int iRet = 0;

    try
    {
        QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

        settings.beginGroup("MainWindow");

        settings.setValue("EditorOption", strEditorOptionPath);

        settings.endGroup();
    }
    catch (QException *ex)
    {
        iRet = -1;
    }

    return iRet;
}


QString CMainWindow::getDiffTool()
{
    QString strDiffToolPath = tr("");

    QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

    settings.beginGroup("MainWindow");

    if(settings.contains("DiffTool"))
    {
        strDiffToolPath = settings.value("DiffTool").toString();
    }

    settings.endGroup();

    return strDiffToolPath;
}


int CMainWindow::saveDiffTool(QString strDiffToolPath)
{
    int iRet = 0;

    try
    {
        QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

        settings.beginGroup("MainWindow");

        settings.setValue("DiffTool", strDiffToolPath);

        settings.endGroup();
    }
    catch (QException *ex)
    {
        iRet = -1;
    }

    return iRet;
}


void CMainWindow::restartSoftware()
{
    QString strFilePath = QCoreApplication::applicationDirPath();// + QDir::separator() /*strExecutePath*/;
    QProcess::startDetached(tr("GrepToolQML"), {}, strFilePath);
}


QString CMainWindow::getVersion()
{
    return QString(VER);
}

void CMainWindow::setPath(const QString Path)
{
    m_Paths.append(Path);
}


int CMainWindow::openFile(const QString &strExecute, const QString &strFileName, const QString &strPath) const
{
    qint64 PID = 0;

    QString strFile = strPath + tr("/") + strFileName;
    if(QFile::exists(strFile))
    {   // If exist
        QFileInfo info(strFile);
        if(info.isReadable())
        {
            QProcess::startDetached(strExecute, {strFileName}, strPath, &PID);
        }
        else
        {
            return -2;
        }
    }
    else
    {  // Not exist
       return -1;
    }

    return 0;
}


int CMainWindow::openFiles(const QString &strExecute) const
{
    qint64 PID = 0;

    for(int i = 0; i < m_Paths.length(); i++)
    {
        QString Path = m_Paths.at(i);

        if(QFile::exists(Path))
        {  // If exist
            QProcess::startDetached(strExecute, {Path}, tr(""), &PID);
        }
        else
        {  // Not exist
            return -1;
        }
    }

    return 0;
}


int CMainWindow::diffFiles(const QString &strExecute, const QString &PathLeft, const QString &PathRight)
{
    qint64 PID = 0;

    if(QFile::exists(PathLeft) && QFile::exists(PathRight))
    {   // If exist
        QFileInfo infoLeft(PathLeft);
        QFileInfo infoRight(PathRight);
        if(infoLeft.isReadable() && infoRight.isReadable())
        {
            QProcess::startDetached(strExecute, {PathLeft, PathRight}, tr(""), &PID);
        }
        else
        {
            return -2;
        }
    }
    else
    {  // Not exist
       return -1;
    }

    return 0;
}


int CMainWindow::removeFile(const QString &Path) const
{
    if(QFile::exists(Path))
    {   // If exist
        if(QFileInfo(Path).isDir())
        {
            QDir Dir(Path);
            if(!Dir.removeRecursively())
            {
                return -2;
            }
        }
        else if(!QFile::remove(Path))
        {   // Error remove file
            return -2;
        }
    }
    else
    {  // Not exist
       return -1;
    }

    return 0;
}


void CMainWindow::startSlot(QString Path, QString Filter, int option)
{
    QEventLoop eventLoop;
    QtConcurrent::run([this, &eventLoop, Path, Filter, option]()
    {
        m_isCancel = false;

        // Check input extension
        QString Extension = Filter;
        if(Filter.isEmpty())
        {   // If extension is empty
            Extension = tr("*");
        }

        QStringList NameFilters = Extension.split(tr(";"));

        //
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
                FileName = info.completeBaseName() + tr(".") + info.suffix(); // Ex. FileName = hoge.abc.d, info = /usr/bin/hoge.abc.d
            }
            else
            {
                FileName = info.completeBaseName();
            }

            emit result(isFile, DirName, FileName);

            lItemCount++;

            std::this_thread::sleep_for(std::chrono::microseconds(1));
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

        eventLoop.quit();
    });
    eventLoop.exec();

    return;
}


void CMainWindow::cancelSlot()
{
    m_isCancel = true;
}
