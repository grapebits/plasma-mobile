/*
 * Copyright 2011 Marco Martin <mart@kde.org>
 * Copyright 2011,2012 Sebastian Kügler <sebas@kde.org>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Library General Public License version 2 as
 * published by the Free Software Foundation
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Library General Public License for more details
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include "previewcontainer.h"
#include "previewengine.h"

#include <QPainter>

#include <KDebug>
#include <KIcon>
#include <KImageCache>


PreviewContainer::PreviewContainer(const QString &name,
                                   const QUrl &url,
                                   QObject *parent)
    : Plasma::DataContainer(parent),
      m_url(url)
{
    setObjectName(name);
    m_previewSize = QSize(180, 120);
}

void PreviewContainer::init()
{
    // Check if the image is in the cache, if so return it
    m_previewEngine = static_cast<PreviewEngine *>(parent());
    QImage preview = QImage(m_previewSize, QImage::Format_ARGB32_Premultiplied);
    if (m_previewEngine->imageCache()->findImage(objectName(), &preview)) {
        // cache hit
        setData("status", "done");
        setData("url", m_url);
        setData("thumbnail", preview);
        checkForUpdate();
        return;
    }

    // Set fallbackimage while loading
    m_fallbackImage = KIcon("image-loading").pixmap(QSize(64, 64)).toImage();
    m_fallbackImage = m_fallbackImage.copy(QRect(QPoint(-120,0), m_previewSize));
    setData("status", "loading");
    setData("url", m_url);
    setData("thumbnail", m_fallbackImage);
    checkForUpdate();

    // It may be a directory or a file, let's stat
    KIO::JobFlags flags = KIO::HideProgressInfo;
    m_mimeJob = KIO::mimetype(m_url, flags);
    connect(m_mimeJob, SIGNAL(mimetype(KIO::Job*,QString)),
            this, SLOT(mimetypeRetrieved(KIO::Job*,QString)));
}

PreviewContainer::~PreviewContainer()
{
}

void PreviewContainer::mimetypeRetrieved(KIO::Job* job, const QString &mimetype)
{
    Q_UNUSED(job)

    if (mimetype.isEmpty() || m_mimeJob->error()) {
        setData("status", "failed");
        //kDebug() << "mimejob failed" << m_mimeJob->url();
        return;
    } else {
        // Make job reusable by keeping the connection open:
        // We want to retrieve the target next to create a preview
        m_mimeJob->putOnHold();
        KIO::Scheduler::publishSlaveOnHold();
    }

    // KIO::PreviewJob: http://api.kde.org/4.x-api/kdelibs-apidocs/kio/html/classKIO_1_1PreviewJob.html
    //kDebug() << "previewengine: starting previewjob for: " << m_url;
    KFileItem kfile = KFileItem(m_url, mimetype, KFileItem::Unknown);
    KFileItemList list;
    list << kfile;

    // Enable all plugins
    QSize previewSize = m_previewSize;
    // FIXME: enable once we depend on Qt 4.8
    //if (!QUrl(m_url).isLocalFile()) {
    if (m_url.toString().startsWith("http")) {
        previewSize = QSize(256, 256); // might come from cache with normalized size
    }
    m_job = new KIO::PreviewJob(list, previewSize,
                                new QStringList(KIO::PreviewJob::availablePlugins()));

    connect(m_job, SIGNAL(gotPreview(KFileItem,QPixmap)),
            SLOT(previewUpdated(KFileItem,QPixmap)));
    connect(m_job, SIGNAL(failed(KFileItem)),
            SLOT(previewJobFailed(KFileItem)));
    connect(m_job, SIGNAL(result(KJob*)), SLOT(previewResult(KJob*)));

    m_job->start();
}

void PreviewContainer::previewJobFailed(const KFileItem &item)
{
    Q_UNUSED(item)

    setData("status", "failed");
    kWarning() << "preview failed for" << m_url;
}

void PreviewContainer::previewResult(KJob* job)
{
    Q_UNUSED( job );
    //kDebug() << "job result:" << job->errorText() << "success?" << (job->error() == 0);
}

void PreviewContainer::previewUpdated(const KFileItem &item, const QPixmap &preview)
{
    Q_UNUSED(item)

    setData("status", "done");
    setData("url", m_url);
    const QRect s(QPoint(0, 0), m_previewSize);
    QImage img(s.size(), QImage::Format_ARGB32_Premultiplied);
    img.fill(Qt::transparent);
    QImage i = preview.toImage();
    if (!item.url().isLocalFile()) {
        // cut out a top-left piece for web previews
        const QSize ss = s.size();
        QRect s1 = QRect(QPoint(0, 0), ss*1.2);
        QRect s2 = QRect(QPoint(0, 0), ss*0.8);
        QPainter p(&img);
        p.drawImage(s1, i, s2);
    } else {
        img = i;
    }
    setData("thumbnail", img);
    checkForUpdate();
    kDebug() << "Cache insert: " << objectName() << img.size();
    m_previewEngine->imageCache()->insertImage(objectName(), img);
}

#include "previewcontainer.moc"
