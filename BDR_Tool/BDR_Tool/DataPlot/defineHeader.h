//
//  defineHeader.h
//  CPK_Test
//
//  Created by RyanGao on 2020/6/27.
//  Copyright © 2020 RyanGao. All rights reserved.
//

#ifndef defineHeader_h
#define defineHeader_h


#define Off                    @"Off"
#define Version                @"Version"
#define Station_ID             @"Station ID"
#define Special_Build_Name     @"Special Build Name"
#define Special_Build_Descrip  @"Special Build Description"
#define Product                @"Product"
#define Channel_ID             @"Channel ID"


#define kRetestSeg             @"key_retest_first_all_last"    //key  retest
#define vRetestFirst           @"retest_first"                 //value first
#define vRetestAll             @"retest_all"                   //value all
#define vRetestLast            @"retest_last"                   //value last

#define kRemoveFailSeg         @"key_remove_fail_yes_no"         // key remove fail
#define vRemoveFailYes         @"remove_fail_yes"               // value remove fail yes
#define vRemoveFailNo          @"remove_fail_no"               // value remove fail yes



#define k_dic_RetestFirst_RemoveFailYes           @"retest_first&remove_fail_yes"       //%@&%@
#define k_dic_RetestAll_RemoveFailYes             @"retest_all&remove_fail_yes"
#define k_dic_RetestLast_RemoveFailYes            @"retest_last&remove_fail_yes"

#define k_dic_RetestFirst_RemoveFailNo           @"retest_first&remove_fail_no"       //%@&%@
#define k_dic_RetestAll_RemoveFailNo             @"retest_all&remove_fail_no"
#define k_dic_RetestLast_RemoveFailNo            @"retest_last&remove_fail_no"


#define k_dic_Version                @"Version"
#define k_dic_Station_ID             @"Station ID"
#define k_dic_Special_Build_Name     @"Special Build Name"
#define k_dic_Special_Build_Desc     @"Special Build Description"
#define k_dic_Channel_ID             @"Channel ID"
#define k_dic_Product                @"Product"
#define k_dic_Channel_ID_Index       @"Item_Channel_ID_Index"
//#define k_dic_Station_Channel_ID     @"Station ID & Channel ID"
//#define k_dic_Station_Channel_ID_Index     @"Station_ID_And_Item_Channel_ID_Index"
#define K_dic_ApplyBoxCheck                @"Apply_Box_Check_or_not"

#define K_dic_Load_Csv_Finished            @"Is_Load_Csv_Finished?"

#define Start_Data             @"Start_Data"
#define End_Data               @"End_Data"

#define kBins                  @"key_bins"                     // key for bins

#define kSelectColorByTableRowsLeft            @"key_select_Table_Rows_Left"             //
#define kSelectColorByTableRowsRight           @"key_select_Table_Rows_Right"             //

#define FCT_RAW_DATA             "FCT_RAW_DATA"
#define FCT_SCRIPT_VERSION       "FCT_SCRIPT_VERSION"
#define FCT_ITEMS_NAME           "FCT_ITEMS_NAME"

#define Load_Csv_Path           @"Load_all_Csv_data_path"

#define kNotificationClickPlotTable            @"Notification_Click_Plot_TableView_Items_left"
#define kNotificationClickPlotTable2           @"Notification_Click_Plot_TableView_Items_right"
#define kNotificationClickPlotTable_selectXY   @"Notification_Click_Plot_select_XY"

#define kNotificationInitColorTable            @"Notification_Init_Color_Table_Control"




#define kNotificationSetCpkImage               @"Notification_Set_Cpk_Image"
#define kNotificationSetCorrelationImage       @"Notification_Set_Correlation_Image"

#define kNotificationSetColorByLeft            @"kNotification_Setting_Color_By_Left"
#define kNotificationSetColorByRight           @"kNotification_Setting_Color_By_Right"
#define select_Color_Box_left                  @"select_Color_Box_Left_Index"
#define select_Color_Box_Right                 @"select_Color_Box_Right_Index"

#define kNotificationSelectX                   @"kNotification_Select_X_Button"
#define kNotificationSelectY                   @"kNotification_Select_Y_Button"
#define kNotificationSetParameters             @"kNotification_Set_Parameters"
#define kNotificationToLoadCsv                 @"kNotification_Load_Csv"
#define btn_select_x                           @"click_select_x_button"
#define btn_select_y                           @"click_select_y_button"

#define imagePath                              @"image_path"
#define paramPath                             @"parameter_Path"
#define applyBoxCheck                          @"is_Apply_Box_Check?"

#define selectXY                               @"selectX_And_Y"




//--------csv col define------
//#define Start_Data_Row                 7
//#define Start_Data_Col                 11
//#define Pass_Fail_Status               7
//#define Product_Col                    1
//#define SerialNumber                   2
//#define SpecialBuildName_Col           3
//#define Special_Build_Descrip_Col      4
//#define StationID_Col                  6
//#define Start_Calc_Data_Col            12
//#define StartTime                      8
//#define Version_Col                    10

#define BC_Col                         11
#define p_val_Col                      12
#define a_q_Cal                        13
#define a_irr_Cal                      14
#define CV3_Cal                        15





//--------UI Table View Display------
#define tb_index      0
#define tb_item       1
#define tb_lower      5
#define tb_upper      4
#define tb_lsl        7
#define tb_usl        8
#define tb_apply      9
#define tb_description      10
#define tb_bc         11
#define tb_p_val      12
#define tb_a_q        13
#define tb_i_irr      14
#define tb_3cv        15

#define tb_color_by_left   31
#define tb_color_by_right  32
#define button_select_x    33
#define button_select_y    34

#define create_empty_line  30
#define tb_script_flag   35
#define tb_data       36
#define tb_data_start       37



#endif /* defineHeader_h */
