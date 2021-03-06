#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QIcon>
#include <iostream>
#include "CRunnable.h"
#include "CMainWindow.h"


int main(int argc, char *argv[])
{
    // Disable multiple activation
    CRunnable Runnable("GrepToolQML-X8WAT-ME6UR-FHCBW-KF739-LWWkV");
    if (!Runnable.tryToRun())
    {
        std::cerr << "GrepToolQML is already running." << std::endl;
        return -1;
    }

#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    QApplication app(argc, argv);

    QApplication::setOrganizationName("Presire");

    // Disable multiple activation
    // Trying to close the Lock File, if the attempt is unsuccessful for 100 milliseconds,
    // then there is a Lock File already created by another process.
    // Therefore, we throw a warning and close the program
    //QLockFile lockFile(QDir::temp().absoluteFilePath("GrepToolQML.lock"));
    //if(!lockFile.tryLock(100))
    //{
    //    return 1;
    //}

    // Set GrepToolQML's Icon
    app.setWindowIcon(QIcon(":/Image/GrepToolQML.png"));

    QSettings settings;
    CMainWindow mainWindow;
    bool bColorMode = mainWindow.getColorMode();
    if (bColorMode)
    {
        QQuickStyle::setStyle("Material");
    }
    else
    {
        QQuickStyle::setStyle("Universal");
    }

    // Register the class so that it can be used in QML
    qmlRegisterType<CMainWindow>("MainWindow", 1, 0, "CMainWindow");

    QQmlApplicationEngine engine;

#ifdef PINEPHONE
    const QUrl url(QStringLiteral("qrc:/mainPinePhone.qml"));
#else
    const QUrl url(QStringLiteral("qrc:/main.qml"));
#endif

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
