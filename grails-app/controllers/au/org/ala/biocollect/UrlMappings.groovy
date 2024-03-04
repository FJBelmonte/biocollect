package au.org.ala.biocollect
import au.org.ala.biocollect.merit.SettingService


class UrlMappings {

        static excludes = ['/plugins']


        static isHubValid(hub) {
                //def settingsService = applicationContext.getBean(SettingService)
                SettingService settingService = grails.util.Holders.applicationContext.getBean('settingService') as SettingService
                return settingService.isValidHub(hub)
        }

        static mappings = {

                "/$hub/$controller/$action?/$id?(.$format)?"{
                        constraints {
                                hub validator: {val, obj -> isHubValid( val)}
                        }
                }

                "/$controller/$action?/$id?(.$format)?"{

                }

                "/"(controller: 'hub', action: 'index')


                "/$hub/$controller/$id?"(parseRequest:true) {
                        constraints {
                                hub validator: {val, obj -> isHubValid( val)}
                        }
                        action = [GET: "get", POST: "upload", PUT: "upload", DELETE: "delete"]
                }

                "/project/getAuditMessagesForProject/$id"(controller: "project", action: 'getAuditMessagesForProject')

                "/activity/$entityId/comment"(controller: "comment"){
                        action = [GET: 'list', POST: 'create']
                        entityType = 'au.org.ala.ecodata.Activity'
                }
                "/activity/$entityId/comment/$id"(controller: 'comment'){
                        entityType = 'au.org.ala.ecodata.Activity'
                        action = [GET: 'get', POST: 'update', PUT: 'update', DELETE: 'delete']
                }


                "/bioActivity/$entityId/comment"(controller: "comment"){
                        action = [GET: 'list', POST: 'create']
                        entityType = 'au.org.ala.ecodata.Activity'
                }
                "/bioActivity/$entityId/comment/$id"(controller: 'comment'){
                        entityType = 'au.org.ala.ecodata.Activity'
                        action = [GET: 'get', POST: 'update', PUT: 'update', DELETE: 'delete']
                }

                "/bioActivity/previewActivity/$formName/$projectId"(controller: "bioActivity", action: 'previewActivity')

//                "/sight/$taxonId**" (controller: 'bioActivity', action: 'create') {
//                       // def grailsApplication = applicationContext.getBean("grailsApplication")
//                        def grailsApplication = grails.util.Holders.applicationContext.getBean('grailsApplication')
//                        id = grailsApplication?.config.individualSightings.pActivity
//                        hub = grailsApplication?.config.individualSightings.hub
//                }

                "/spotter/$spotterId" (controller: 'bioActivity', action: 'spotter')

                "/$controller/$id?"(parseRequest:true) {

                        action = [GET: "get", POST: "upload", PUT: "upload", DELETE: "delete"]
                }

                "/$hub/"(controller: 'hub', action: 'index') {
                        constraints {
                                hub validator: {val, obj -> isHubValid( val)}
                        }
                }
                "/$hub"(controller: 'hub', action: 'index') {
                        constraints {
                                hub validator: {val, obj -> isHubValid( val)}
                        }
                }

                "/$hub/requestAssessmentRecords"(controller: 'hub', action: 'requestAssessmentRecords') {
                        constraints {
                                hub validator: {val, obj -> isHubValid(val) && val == grailsApplication.config.refAssess.hub}
                        }
                }

                "/$hub/nocas/geoService"(controller: 'home', action: 'geoService') {
                        constraints {
                                hub validator: {val, obj -> isHubValid( val)}
                        }
                }
                "/nocas/geoService"(controller: 'home', action: 'geoService') {

                }
                "/$hub/myProfile"(controller: 'home', action: 'myProfile') {
                        constraints {
                                hub validator: {val, obj -> isHubValid( val)}
                        }
                }
                "/myProfile"(controller: 'home', action: 'myProfile') {

                }

                "/$hub/admin/user/$id"(controller: "user", action: "show") {
                        constraints {
                                hub validator: {val, obj -> isHubValid( val)}
                        }
                }
                "/admin/user/$id"(controller: "user", action: "show") {

                }
                "/download/file"(controller: "download", action: [GET: "file"])
                "/download/$id"(controller: "download", action: [GET: "downloadProjectDataFile"])
                "/download/getScriptFile"(controller: "download", action: [GET: "getScriptFile"])
                "/document/download/$path/$filename" {
                        controller = 'document'
                        action = 'download'
                }

                "/document/download/$filename" {
                        controller = 'document'
                        action = 'download'
                }

                "/$hub/bulkImport" {
                        controller = 'bulkImport'
                        action = [GET: 'list', POST:'create']
                        format = 'json'
                }
                "/$hub/bulkImport/list" {
                        controller = 'bulkImport'
                        action = [GET: 'listings']
                        format = 'html'
                }
                "/$hub/bulkImport/create" {
                        controller = 'bulkImport'
                        action = [GET: 'createPage']
                        format = 'html'
                }
                "/$hub/bulkImport/index/$id" {
                        controller = 'bulkImport'
                        action = [GET: 'index']
                        format = 'html'
                }
                "/$hub/bulkImport/$id" {
                        controller = 'bulkImport'
                        action = [GET: 'get', PUT:'update']
                        format = 'json'
                }
                "/$hub/bulkImport/$id/activity" {
                        controller = 'bulkImport'
                        action = [DELETE: 'deleteActivitiesImported']
                        format = 'json'
                }
                "/$hub/bulkImport/$id/activity/list" {
                        controller = 'bioActivity'
                        action = [GET: 'bulkImport']
                        format = 'html'
                }
                "/$hub/bulkImport/$id/activity/publish" {
                        controller = 'bulkImport'
                        action = [POST: 'publishActivitiesImported', PUT: 'publishActivitiesImported']
                        format = 'json'
                }
                "/$hub/bulkImport/$id/activity/embargo" {
                        controller = 'bulkImport'
                        action = [POST: 'embargoActivitiesImported', PUT: 'embargoActivitiesImported']
                        format = 'json'
                }

                "500"(controller:'error', action:'response500')
                "404"(controller:'error', action:'response404')


                // Following api's are used by external mobile clients
                "/ws/referenceAssessment/requestRecords/$projectId"(controller: "referenceAssessment", action: "requestRecords")

                "/ws/project/search"(controller: "project", action: 'search')
                "/ws/survey/list/$id"(controller:  "project", action: 'listSurveys')
                "/ws/attachment/upload"(controller:  "image", action: 'upload')
                "/ws/bioactivity/model/$id"(controller: "bioActivity", action: 'getActivityModel')
                "/ws/bioactivity/data/$id"(controller:  "bioActivity", action: 'getOutputForActivity')
                "/ws/species/uniqueId"(controller:  "output", action: 'getOutputSpeciesIdentifier')
                "/ws/bioactivity/save"(controller:  "bioActivity", action: 'ajaxUpdate')
                "/ws/bioactivity/site"(controller:  "site", action: 'ajaxUpdate')
                "/ws/bioactivity/delete/$id"(controller:  "bioActivity", action: 'delete')
                "/ws/bioactivity/search"(controller:  "bioActivity", action: 'searchProjectActivities')
                "/ws/bioactivity/map"(controller:  "bioActivity", action: 'getProjectActivitiesRecordsForMapping')
        }
}

