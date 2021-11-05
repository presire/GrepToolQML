#ifndef CMAINWINDOW_H
#define CMAINWINDOW_H

#include <QCoreApplication>
#include <QObject>
#include <QSettings>
#include <QProcess>
#include <QException>
#include <QtConcurrent/qtconcurrentrun.h>
#include <QStandardPaths>
#include <QDirIterator>
#include <QDir>
#include <QFile>
#include <thread>
#include "CWorkerThread.h"
#include "CAES.h"


class CMainWindow : public QObject
{
    Q_OBJECT

private:    // Private Variables
    QString     m_strIniFilePath;
    QString     m_UserName;
    QStringList m_HomePath;
    QStringList m_Paths;

    std::unique_ptr<CWorkerThread>  m_pWorker;
    std::unique_ptr<QThread>        m_pThread;

    std::atomic_bool    m_isCancel;


public:     // Public Variables


private:    // Private Functions


public:     // Public Functions
    explicit CMainWindow(QObject *parent = nullptr);
    virtual ~CMainWindow();

    Q_INVOKABLE int     getMainWindowX();
    Q_INVOKABLE int     getMainWindowY();
    Q_INVOKABLE int     getMainWindowWidth();
    Q_INVOKABLE int     getMainWindowHeight();
    Q_INVOKABLE bool    getMainWindowMaximized();
    Q_INVOKABLE int     setMainWindowState(int X, int Y, int Width, int Height, bool Maximized);
    Q_INVOKABLE bool    getColorMode();
    Q_INVOKABLE int     setColorMode(bool bDarkMode);
    Q_INVOKABLE QString getPassword();
    Q_INVOKABLE int     savePassword(QString strPassword);

    Q_INVOKABLE QString getDirectory();
    Q_INVOKABLE int     saveDirectory(QString strDirectoryPath);
    Q_INVOKABLE QString getExtension();
    Q_INVOKABLE int     saveExtension(QString strExtension);
    Q_INVOKABLE QString getEditor();
    Q_INVOKABLE int     saveEditor(QString strEditorPath);
    Q_INVOKABLE QString getEditorOption();
    Q_INVOKABLE int     saveEditorOption(QString strEditorOptionPath);
    Q_INVOKABLE QString getDiffTool();
    Q_INVOKABLE int     saveDiffTool(QString strDiffToolPath);

    Q_INVOKABLE void    restartSoftware();
    Q_INVOKABLE QString getVersion();

    //Q_INVOKABLE void    startSearch(QString Path, QString Filter, int option);
    //Q_INVOKABLE void    cancelSearch();

    Q_INVOKABLE void setPath(const QString Path);
    Q_INVOKABLE int  openFile(const QString &strExecute, const QString &strFileName, const QString &strPath) const;
    Q_INVOKABLE int  openFiles(const QString &strExecute) const;
    Q_INVOKABLE int  diffFiles(const QString &strExecute, const QString &PathLeft, const QString &PathRight);
    Q_INVOKABLE int  removeFile(const QString &Path) const;


signals:
    void startSignal(QString Path, QString Filter, int option);
    void cancelSignal();
    void result(int isFile, QString DirName, QString FileName);
    void resultCancel();
    void resultDone(QString strItemCount);


public slots:
    void startSlot(QString Path, QString Filter, int option);
    void cancelSlot();
};

#endif // CMAINWINDOW_H
