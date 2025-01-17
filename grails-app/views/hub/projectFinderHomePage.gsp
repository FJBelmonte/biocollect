<%@ page import="grails.converters.JSON; au.org.ala.biocollect.merit.SettingPageType" contentType="text/html;charset=UTF-8" %>
<g:set var="mapService" bean="mapService"></g:set>
<!DOCTYPE HTML>
<html xmlns="http://www.w3.org/1999/html">
<head>
    <meta name="layout" content="bs4"/>
    <title><g:message code="hub.projectFinder"/> | ${hubConfig.title}</title>
    <asset:stylesheet src="project-finder-manifest.css"/>
%{--    <asset:stylesheet src="project-finder.css" />--}%
    <asset:script type="text/javascript">
    var fcConfig = {
        <g:applyCodec encodeAs="none">
        intersectService: "${createLink(controller: 'proxy', action: 'intersect')}",
        featuresService: "${createLink(controller: 'proxy', action: 'features')}",
        featureService: "${createLink(controller: 'proxy', action: 'feature')}",
        spatialWms: "${grailsApplication.config.spatial.geoserverUrl}",
        layersStyle: "${createLink(controller: 'regions', action: 'layersStyle')}",
        baseUrl: "${grailsApplication.config.grails.serverURL}",
        spatialService: '${createLink(controller:'proxy',action:'feature')}',
        intersectService: "${createLink(controller: 'proxy', action: 'intersect')}",
        regionListUrl: "${createLink(controller: 'regions', action: 'regionsList')}",
        featuresService: "${createLink(controller: 'proxy', action: 'features')}",
        featureService: "${createLink(controller: 'proxy', action: 'feature')}",
        spatialWms: "${grailsApplication.config.spatial.geoserverUrl}",
        geocodeUrl: "${raw(grailsApplication.config.google.geocode.url)}",
        siteMetaDataUrl: "${createLink(controller:'site', action:'locationMetadataForPoint')}",
        spatialBaseUrl: "${grailsApplication.config.spatial.baseURL}",
        spatialWmsCacheUrl: "${grailsApplication.config.spatial.wms.cache.url}",
        spatialWmsUrl: "${grailsApplication.config.spatial.wms.url}",
        sldPolgonDefaultUrl: "${grailsApplication.config.sld.polgon.default.url}",
        sldPolgonHighlightUrl: "${grailsApplication.config.sld.polgon.highlight.url}",
        organisationLinkBaseUrl: "${createLink(controller: 'organisation', action: 'index')}",
        imageLocation:"${asset.assetPath(src:'')}",
        logoLocation:"${asset.assetPath(src:'filetypes')}",
        isUserPage: false,
        <g:if test="${hubConfig.defaultFacetQuery.contains('isWorks:true')}">
            isUserWorksPage: true,
        </g:if>
        <g:if test="${hubConfig.defaultFacetQuery.contains('isEcoScience:true')}">
            isUserEcoSciencePage: true,
        </g:if >
        <g:if test="${hubConfig.defaultFacetQuery.contains('isCitizenScience:true')}">
            isCitizenScience: true,
        </g:if>
        projectListUrl: "${raw(createLink(controller: 'project', action: 'search', params:[initiator:'biocollect']))}",
        projectIndexBaseUrl : "${createLink(controller:'project',action:'index')}/",
        organisationBaseUrl : "${createLink(controller:'organisation',action:'index')}/",
        defaultSearchRadiusMetersForPoint: "${grailsApplication.config.defaultSearchRadiusMetersForPoint ?: "100"}",
        showAllProjects: false,
        meritProjectLogo:"${asset.assetPath(src:'merit_project_logo.jpg')}",
        meritProjectUrl: "${grailsApplication.config.merit.project.url}",
        hideWorldWideBtn: ${!hubConfig?.templateConfiguration?.homePage?.projectFinderConfig?.showProjectRegionSwitch},
        flimit: ${grailsApplication.config.facets.flimit},
        noImageUrl: '${asset.assetPath(src: "font-awesome/5.15.4/svgs/regular/image.svg")}',
        sciStarterImageUrl: '${asset.assetPath(src: 'robot.png')}',
        paginationMessage: '${hubConfig.getTextForShowingProjects(grailsApplication.config.content.defaultOverriddenLabels)}',
        enablePartialSearch: ${hubConfig.content.enablePartialSearch?:false},
        downloadWorksProjectsUrl: "${createLink(controller:'project', action:'downloadWorksProjects')}",
        mapLayersConfig: <fc:modelAsJavascript model="${mapService.getMapLayersConfig(project, pActivity)}"/>,
        </g:applyCodec>
        dashboardUrl: "${raw(g.createLink(controller: 'report', action: 'dashboardReport', params: params))}"
  }
    </asset:script>
    <g:render template="/shared/conditionalLazyLoad"/>
    <asset:javascript src="common-bs4.js" />
    <asset:javascript src="projects-manifest.js" />
    <asset:javascript src="project-finder.js" />
    <script src="${grailsApplication.config.google.maps.url}" async defer></script>
</head>
<body>
<content tag="pagefinderbuttons">
    <g:if test="${isUserPage}">
        <button id="newPortal" type="button" class="btn btn-primary-dark"><g:message
                code="project.citizenScience.portalLink"/></button>
    </g:if>
    <g:else>
        <g:if test="${!hubConfig.content?.hideProjectFinderHelpButtons}">
            <button class="btn btn-primary-dark btn-gettingstarted"
                    onclick="window.location = '<g:createLink controller="home" action="gettingStarted" />'">
                <i class="fas fa-info"></i> Getting started</button>
            <button class="btn btn-primary-dark btn-whatisthis"
                    onclick="window.location = '<g:createLink controller='home' action='whatIsThis' />'">
                <i class="fas fa-question"></i> What is this?</button>
        </g:if>
    </g:else>
</content>
<content tag="bannertitle">
    ${hubConfig.title}
</content>
<g:render template="/shared/bannerHub"/>
<g:set var="intro" value="${fc.homePageIntro()}"/>
<g:if test="intro">
    <div class="container-fluid">
        <div class="row">
            <div class="col-12">
                ${intro}
            </div>
        </div>
    </div>
</g:if>
<section id="catalogueSection">
    <div id="project-finder-container">
        <div class="container-fluid show expander projects-container">
            <g:render template="/shared/projectFinderResultSummary" />
            <g:render template="/shared/projectFinderResultPanel"/>
        </div>
        <g:render template="/shared/projectFinderQueryPanel" model="${[showSearch: false]}"/>
    </div>
</section>

<asset:script type="text/javascript">
    if (!amplify.store('pt-view-state')) {
    <g:if test="${hubConfig?.templateConfiguration?.homePage?.projectFinderConfig?.defaultView == 'grid'}">
        amplify.store('pt-view-state','tileView');
    </g:if>
    <g:elseif test="${hubConfig?.templateConfiguration?.homePage?.projectFinderConfig?.defaultView == 'list'}">
        amplify.store('pt-view-state','listView');
    </g:elseif>
    }
    var projectFinder = new ProjectFinder(fcConfig);
</asset:script>
<g:render template="/shared/resizeFilter" model="[dependentDiv: '#project-finder-container .projects-container',
                                                  target: '#project-finder-container #filters',
                                                  listenTo: '#project-finder-container']" />
</body>
</html>
