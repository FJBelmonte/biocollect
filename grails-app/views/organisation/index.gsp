<%@ page import="grails.converters.JSON;" contentType="text/html;charset=UTF-8" %>
<g:set var="mapService" bean="mapService"></g:set>
<g:set var="utilService" bean="utilService"></g:set>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="bs4"/>
    <title>${organisation.name.encodeAsHTML()} | <g:message code="g.biocollect"/></title>
    <meta name="breadcrumbParent1" content="${createLink(uri: '/'+ hubConfig.urlPath)},Home"/>
    <meta name="breadcrumbParent2"
          content="${createLink(controller: 'organisation', action: 'list')},Organisations"/>
    <meta name="breadcrumb" content="${organisation.name}"/>
    <meta name="bannerURL" content="${utilService.getMainImageURL(organisation.documents)}"/>
    <g:set var="loadPermissionsUrl"
           value="${createLink(controller: 'organisation', action: 'getMembersForOrganisation', id: organisation.organisationId)}"/>
    <asset:script type="text/javascript">
        var fcConfig = {
        <g:applyCodec encodeAs="none">
            intersectService: "${createLink(controller: 'proxy', action: 'intersect')}",
            featuresService: "${createLink(controller: 'proxy', action: 'features')}",
            featureService: "${createLink(controller: 'proxy', action: 'feature')}",
            spatialWms: "${grailsApplication.config.spatial.geoserverUrl}",
            layersStyle: "${createLink(controller: 'regions', action: 'layersStyle')}",
            serverUrl: "${grailsApplication.config.grails.serverURL}",
            viewProjectUrl: "${createLink(controller: 'project', action: 'index')}",
            updateProjectUrl: "${createLink(controller: 'project', action: 'ajaxUpdate')}",
            documentUpdateUrl: '${g.createLink(controller: "proxy", action: "documentUpdate")}',
            documentDeleteUrl: '${g.createLink(controller: "proxy", action: "deleteDocument")}',
            organisationDeleteUrl: '${g.createLink(action: "ajaxDelete", id: "${organisation.organisationId}")}',
            organisationEditUrl: '${g.createLink(action: "edit", id: "${organisation.organisationId}")}',
            organisationListUrl: '${g.createLink(action: "list")}',
            organisationViewUrl: '${g.createLink(action: "index", id: "${organisation.organisationId}")}',
            organisationMembersUrl: "${loadPermissionsUrl}",
            regionListUrl: "${createLink(controller: 'regions', action: 'regionsList')}",
            imageLocation:"${asset.assetPath(src: '')}",
            logoLocation:"${asset.assetPath(src: 'filetypes')}",
            adHocReportsUrl: '${g.createLink(action: "getAdHocReportTypes")}',
            dashboardUrl: "${raw(g.createLink(controller: 'report', action: 'loadReport', params: [fq: 'organisationFacet:' + organisation.name]))}",
            reportCreateUrl: '${g.createLink(action: 'createAdHocReport')}',
            submitReportUrl: '${g.createLink(action: 'ajaxSubmitReport', id: "${organisation.organisationId}")}',
            approveReportUrl: '${g.createLink(action: 'ajaxApproveReport', id: "${organisation.organisationId}")}',
            spatialService: '${createLink(controller: 'proxy', action: 'feature')}',
            spatialWmsUrl: "${grailsApplication.config.spatial.wms.url}",
            rejectReportUrl: '${g.createLink(action: 'ajaxRejectReport', id: "${organisation.organisationId}")}',
            defaultSearchRadiusMetersForPoint: "${grailsApplication.config.defaultSearchRadiusMetersForPoint ?: "100"}",
            returnTo: '${g.createLink(action: 'index', id: "${organisation.organisationId}")}',
            projects : <fc:modelAsJavascript model="${organisation.projects}"/>,
            projectListUrl: "${raw(createLink(controller: 'project', action: 'search', params: [initiator: 'biocollect']))}",
            projectIndexBaseUrl : "${createLink(controller: 'project', action: 'index')}/",
            organisationBaseUrl : "${createLink(controller: 'organisation', action: 'index')}/",
            organisation : <fc:modelAsJavascript model="${organisation}"/>,
            organisationName : "${organisation.name}",
            showAllProjects: true,
            meritProjectLogo:"${asset.assetPath(src: 'merit_project_logo.jpg')}",
            meritProjectUrl: "${grailsApplication.config.merit.project.url}",

            searchProjectActivitiesUrl: "${createLink(controller: 'bioActivity', action: 'searchProjectActivities')}",
            projectLinkPrefix: "${createLink(controller: 'project')}/",
            bieUrl: "${grailsApplication.config.bie.baseURL}",
            bieWsUrl: "${grailsApplication.config.bieWs.baseURL}",
            siteViewUrl: "${createLink(controller: 'site', action: 'index')}",
            projectIndexUrl: "${createLink(controller: 'project', action: 'index')}",
            worksActivityEditUrl: "${createLink(controller: 'activity', action: 'enterData')}",
            worksActivityViewUrl: "${createLink(controller: 'activity', action: 'index')}",
            downloadProjectDataUrl: "${createLink(controller: 'bioActivity', action: 'downloadProjectData')}",
            activityUpdateUrl: "${createLink(controller: 'activity', action: 'ajaxUpdate')}",
            activityViewUrl: "${createLink(controller: 'bioActivity', action: 'index')}",
            activityEditUrl: "${createLink(controller: 'bioActivity', action: 'edit')}",
            activityDeleteUrl: "${createLink(controller: 'bioActivity', action: 'delete')}",
            activityAddUrl: "${createLink(controller: 'bioActivity', action: 'create')}",
            activityListUrl: "${createLink(controller: 'bioActivity', action: 'ajaxList')}",
            recordImageListUrl: '${createLink(controller: "project", action: "listRecordImages")}',
            imageLeafletViewer: '${createLink(controller: 'resource', action: 'imageviewer', absolute: true)}',
            hideWorldWideBtn: true,
            flimit: ${grailsApplication.config.facets.flimit},
            occurrenceUrl: "",
            spatialUrl: "",
            paginationMessage: '${hubConfig.getTextForShowingProjects(grailsApplication.config.content.defaultOverriddenLabels)}',
            absenceIconUrl:"${asset.assetPath(src: 'triangle.png')}",
            mapLayersConfig: <fc:modelAsJavascript model="${mapService.getMapLayersConfig(project, null)}"/>,
            </g:applyCodec>
            getRecordsForMapping: "${raw(createLink(controller: 'bioActivity', action: 'getProjectActivitiesRecordsForMapping'))}",
            version: "${params.version ?: ''}"
        };
    </asset:script>
    <g:render template="/shared/conditionalLazyLoad"/>
    <asset:stylesheet src="project-finder-manifest.css"/>
    <asset:javascript src="org-index-manifest.js"/>
    <script src="${grailsApplication.config.google.maps.url}" async defer></script>
</head>

<body>

<g:render template="banner" model="${[organisation: organisation]}"/>

<div id="organisationDetails" class="container-fluid">

    <g:render template="/shared/flashScopeMessage"/>

    <content tag="tab">
        <ul class="nav nav-tabs" id="tabs" data-tabs="tabs" role="tablist">
            <fc:tabList tabs="${content}"/>
        </ul>
    </content>

    <div class="row" id="heading">
        <div class="col-12">
            <div class="tab-content">
                <fc:tabContent tabs="${content}"/>
            </div>
        </div>
    </div>

    <div id="loading" class="text-center">
        <img width="50px" src="${asset.assetPath(src: 'loading.gif')}" alt="loading icon"/>
    </div>
</div>

<g:render template="/shared/declaration"/>

<asset:script type="text/javascript">

    $(function () {

        var organisation =<fc:modelAsJavascript model="${organisation}"/>;
        var organisationViewModel = new OrganisationViewModel(organisation);

        ko.applyBindings(organisationViewModel);
        $('#loading').hide();

        var SELECTED_REPORT_KEY = 'selectedOrganisationReport';
        var selectedReport = amplify.store(SELECTED_REPORT_KEY);
        var $dashboardType = $('#dashboardType');
        // This check is to prevent errors when a particular organisation is missing a report or the user
        // permission set if different when viewing different organisations.
        if (!$dashboardType.find('option[value='+selectedReport+']')[0]) {
           selectedReport = 'dashboard';
        }
        $dashboardType.val(selectedReport);
        $dashboardType.on('change',function(e) {
            var $content = $('#dashboard-content');
            var $loading = $('.loading-message');
            $content.hide();
            $loading.show();

            var reportType = $dashboardType.val();

            $.get(fcConfig.dashboardUrl, {report:reportType}).done(function(data) {
                $content.html(data);
                $loading.hide();
                $content.show();
                $('#dashboard-content .helphover').popover({animation: true, trigger:'hover', container:'body'});
                amplify.store(SELECTED_REPORT_KEY, reportType);
            });

        }).trigger('change');

        var organisationTabStorageKey = 'organisation-page-tab';
        var initialisedSites = false;
        $('a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
            var tab = e.currentTarget.hash;
            amplify.store(organisationTabStorageKey, tab);
            if (!initialisedSites && tab == '#sites') {
                generateMap(['organisationFacet:'+organisation.name]);
                initialisedSites = true;
            }
        });

        var storedTab = amplify.store(organisationTabStorageKey);

        if (storedTab) {
            $(storedTab + '-tab').tab('show');
        }
    <g:if test="${content.admin.visible}">
        populatePermissionsTable(fcConfig.organisationMembersUrl);
    </g:if>

    initialiseData("allrecords");
});
$(function() {
    var projectFinder = new ProjectFinder({enablePartialSearch: ${hubConfig.content.enablePartialSearch ?: false}});
    });
</asset:script>
<g:render template="/shared/resizeFilter" model="[dependentDiv: '#project-finder-container .projects-container', target: '#projects #filters', listenTo: '#project-finder-container']" />
</body>

</html>
