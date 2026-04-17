/*
 Navicat Premium Data Transfer

 Source Server         : mylocal
 Source Server Type    : MySQL
 Source Server Version : 50726
 Source Host           : 127.0.0.1:3306
 Source Schema         : chatweb

 Target Server Type    : MySQL
 Target Server Version : 50726
 File Encoding         : 65001

 Date: 17/04/2026 13:25:50
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for ai_model
-- ----------------------------
DROP TABLE IF EXISTS `ai_model`;
CREATE TABLE `ai_model`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '关联用户ID',
  `gender` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '性别:Male/Female',
  `layers` json NOT NULL COMMENT '图层配置JSON',
  `update_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建或者更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uniq_user_gender`(`username`, `gender`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'AI模型配置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ai_model
-- ----------------------------
INSERT INTO `ai_model` VALUES (2, 'B', 'Female', '\"[{\\\"category\\\":\\\"d_model\\\",\\\"id\\\":\\\"9f359a4a-f6da-48cf-a8d9-e91a93224f74\\\",\\\"image\\\":\\\"/static/img/a默认.825f962.png\\\",\\\"resizable\\\":true,\\\"snappable\\\":true,\\\"zIndex\\\":1,\\\"style\\\":{\\\"width\\\":\\\"506px\\\",\\\"height\\\":\\\"573px\\\",\\\"left\\\":\\\"50%\\\",\\\"top\\\":\\\"50%\\\",\\\"rotate\\\":0,\\\"zIndex\\\":1,\\\"transform\\\":\\\" translate(-50%, -50%)\\\"}},{\\\"category\\\":\\\"前发a_front\\\",\\\"id\\\":\\\"5d64082f-9f53-4890-8a02-58457f547852\\\",\\\"image\\\":\\\"/static/img/Blond.a2f629b.png\\\",\\\"resizable\\\":true,\\\"snappable\\\":true,\\\"zIndex\\\":10,\\\"style\\\":{\\\"width\\\":\\\"214px\\\",\\\"height\\\":\\\"271px\\\",\\\"left\\\":0,\\\"top\\\":0,\\\"rotate\\\":0,\\\"zIndex\\\":10,\\\"transform\\\":\\\" translate(292px, 170px) \\\"}},{\\\"category\\\":\\\"ny\\\",\\\"id\\\":\\\"81c7969c-4bad-4ef3-bec8-b693bda08e81\\\",\\\"image\\\":\\\"/static/img/1.82fe57d.png\\\",\\\"resizable\\\":true,\\\"snappable\\\":true,\\\"zIndex\\\":10,\\\"style\\\":{\\\"width\\\":\\\"234px\\\",\\\"height\\\":\\\"198px\\\",\\\"left\\\":0,\\\"top\\\":0,\\\"rotate\\\":0,\\\"zIndex\\\":10,\\\"transform\\\":\\\" translate(279px, 484px) \\\"}},{\\\"category\\\":\\\"c_clothes\\\",\\\"id\\\":\\\"20472784-a344-43e5-83a0-98b507457df5\\\",\\\"image\\\":\\\"/static/img/Casual 1.6313fcf.png\\\",\\\"resizable\\\":true,\\\"snappable\\\":true,\\\"zIndex\\\":10,\\\"style\\\":{\\\"width\\\":\\\"331px\\\",\\\"height\\\":\\\"261px\\\",\\\"left\\\":0,\\\"top\\\":0,\\\"rotate\\\":0,\\\"zIndex\\\":100,\\\"transform\\\":\\\" translate(230px, 466px) \\\"}}]\"', '2026-04-16 08:09:06');
INSERT INTO `ai_model` VALUES (3, 'D', 'Male', '\"[{\\\"category\\\":\\\"d_model\\\",\\\"id\\\":\\\"3ea8919d-4342-4df6-82f3-f11b82808cb5\\\",\\\"image\\\":\\\"/static/img/a默认.45987cd.png\\\",\\\"resizable\\\":true,\\\"snappable\\\":true,\\\"zIndex\\\":1,\\\"style\\\":{\\\"width\\\":\\\"579px\\\",\\\"height\\\":\\\"644px\\\",\\\"left\\\":\\\"50%\\\",\\\"top\\\":\\\"50%\\\",\\\"rotate\\\":0,\\\"zIndex\\\":1,\\\"transform\\\":\\\" translate(-50%, -50%)\\\"}},{\\\"category\\\":\\\"前发a_front\\\",\\\"id\\\":\\\"6a461ab5-8646-4b4e-8f64-1aef1000eacb\\\",\\\"image\\\":\\\"/static/img/Black4.2ffd307.png\\\",\\\"resizable\\\":true,\\\"snappable\\\":true,\\\"zIndex\\\":10,\\\"style\\\":{\\\"width\\\":\\\"223px\\\",\\\"height\\\":\\\"202px\\\",\\\"left\\\":0,\\\"top\\\":0,\\\"rotate\\\":0,\\\"zIndex\\\":10,\\\"transform\\\":\\\" translate(277px, 143px) \\\"}},{\\\"category\\\":\\\"ny\\\",\\\"id\\\":\\\"c0f32ef1-a446-4753-9840-0ddbc6faaeb0\\\",\\\"image\\\":\\\"/static/img/2.a900bbf.png\\\",\\\"resizable\\\":true,\\\"snappable\\\":true,\\\"zIndex\\\":10,\\\"style\\\":{\\\"width\\\":\\\"300px\\\",\\\"height\\\":\\\"233px\\\",\\\"left\\\":0,\\\"top\\\":0,\\\"rotate\\\":0,\\\"zIndex\\\":10,\\\"transform\\\":\\\"translate(249px, 489px)\\\"}},{\\\"category\\\":\\\"b_decorate\\\",\\\"id\\\":\\\"7b2dff4a-74ef-43a0-90a2-84154e3d27ae\\\",\\\"image\\\":\\\"/static/img/Black Glasses Copy.4f1a1f9.png\\\",\\\"resizable\\\":true,\\\"snappable\\\":true,\\\"zIndex\\\":10,\\\"style\\\":{\\\"width\\\":\\\"167px\\\",\\\"height\\\":\\\"45px\\\",\\\"left\\\":0,\\\"top\\\":0,\\\"rotate\\\":0,\\\"zIndex\\\":100,\\\"transform\\\":\\\" translate(304px, 315px) \\\"}}]\"', '2025-03-28 07:26:07');
INSERT INTO `ai_model` VALUES (4, '13333333333', 'Female', '\"[{\\\"category\\\":\\\"d_model\\\",\\\"id\\\":\\\"9623c8d8-234c-4df0-b0ca-5f5329912891\\\",\\\"image\\\":\\\"/static/img/a默认.825f962.png\\\",\\\"resizable\\\":true,\\\"snappable\\\":true,\\\"zIndex\\\":1,\\\"style\\\":{\\\"width\\\":\\\"506px\\\",\\\"height\\\":\\\"573px\\\",\\\"left\\\":\\\"50%\\\",\\\"top\\\":\\\"50%\\\",\\\"rotate\\\":0,\\\"zIndex\\\":1,\\\"transform\\\":\\\" translate(-50%, -50%)\\\"}},{\\\"category\\\":\\\"前发a_front\\\",\\\"id\\\":\\\"163fb785-3b50-4b3e-8a11-e1009898a659\\\",\\\"image\\\":\\\"/static/img/Blond.a2f629b.png\\\",\\\"resizable\\\":true,\\\"snappable\\\":true,\\\"zIndex\\\":10,\\\"style\\\":{\\\"width\\\":\\\"214px\\\",\\\"height\\\":\\\"271px\\\",\\\"left\\\":0,\\\"top\\\":0,\\\"rotate\\\":0,\\\"zIndex\\\":10,\\\"transform\\\":\\\"translate(290px, 196px)\\\"}},{\\\"category\\\":\\\"ny\\\",\\\"id\\\":\\\"fc4db0d4-252b-4c53-ae02-7b9c5f94bf0f\\\",\\\"image\\\":\\\"/static/img/1.82fe57d.png\\\",\\\"resizable\\\":true,\\\"snappable\\\":true,\\\"zIndex\\\":10,\\\"style\\\":{\\\"width\\\":\\\"234px\\\",\\\"height\\\":\\\"198px\\\",\\\"left\\\":0,\\\"top\\\":0,\\\"rotate\\\":0,\\\"zIndex\\\":10,\\\"transform\\\":\\\"translate(281px, 487px)\\\"}},{\\\"category\\\":\\\"b_decorate\\\",\\\"id\\\":\\\"bdbb12a0-6ee4-4357-9419-579adb67248a\\\",\\\"image\\\":\\\"/static/img/Circle Glasses.8b37612.png\\\",\\\"resizable\\\":true,\\\"snappable\\\":true,\\\"zIndex\\\":10,\\\"style\\\":{\\\"width\\\":\\\"0px\\\",\\\"height\\\":\\\"74px\\\",\\\"left\\\":0,\\\"top\\\":0,\\\"rotate\\\":0,\\\"zIndex\\\":10,\\\"transform\\\":\\\" translate(619px, 409px) \\\"}},{\\\"category\\\":\\\"c_clothes\\\",\\\"id\\\":\\\"2d0a8743-62d9-444c-930e-bb296b28f4c5\\\",\\\"image\\\":\\\"/static/img/PE uniform1.cf6d666.png\\\",\\\"resizable\\\":true,\\\"snappable\\\":true,\\\"zIndex\\\":10,\\\"style\\\":{\\\"width\\\":\\\"358px\\\",\\\"height\\\":\\\"234px\\\",\\\"left\\\":0,\\\"top\\\":0,\\\"rotate\\\":0,\\\"zIndex\\\":100,\\\"transform\\\":\\\" translate(222px, 450px) \\\"}},{\\\"category\\\":\\\"b_decorate\\\",\\\"id\\\":\\\"0f251d61-979b-4d12-8589-67aaa2b4e585\\\",\\\"image\\\":\\\"/static/img/Band 2.8c83c8f.png\\\",\\\"resizable\\\":true,\\\"snappable\\\":true,\\\"zIndex\\\":10,\\\"style\\\":{\\\"width\\\":\\\"183px\\\",\\\"height\\\":\\\"71px\\\",\\\"left\\\":0,\\\"top\\\":0,\\\"rotate\\\":0,\\\"zIndex\\\":10,\\\"transform\\\":\\\" translate(309px, 191px) \\\"}},{\\\"category\\\":\\\"b_decorate\\\",\\\"id\\\":\\\"f6746ce8-f066-4939-a99a-24bb108cefbb\\\",\\\"image\\\":\\\"/static/img/Black Glasses.2e38fb2.png\\\",\\\"resizable\\\":true,\\\"snappable\\\":true,\\\"zIndex\\\":10,\\\"style\\\":{\\\"width\\\":\\\"178px\\\",\\\"height\\\":\\\"47px\\\",\\\"left\\\":0,\\\"top\\\":0,\\\"rotate\\\":0,\\\"zIndex\\\":10,\\\"transform\\\":\\\" translate(304px, 342px) \\\"}}]\"', '2025-03-28 15:04:16');
INSERT INTO `ai_model` VALUES (5, 'admin', 'Male', '\"[{\\\"category\\\":\\\"d_model\\\",\\\"id\\\":\\\"427be175-744d-4fd4-8595-9332d71247fb\\\",\\\"image\\\":\\\"/static/img/a默认.45987cd.png\\\",\\\"resizable\\\":true,\\\"snappable\\\":true,\\\"zIndex\\\":1,\\\"style\\\":{\\\"width\\\":\\\"579px\\\",\\\"height\\\":\\\"644px\\\",\\\"left\\\":\\\"50%\\\",\\\"top\\\":\\\"50%\\\",\\\"rotate\\\":0,\\\"zIndex\\\":1,\\\"transform\\\":\\\" translate(-50%, -50%)\\\"}},{\\\"category\\\":\\\"前发a_front\\\",\\\"id\\\":\\\"8ef6e15b-47be-42ed-8b15-80da18a90e39\\\",\\\"image\\\":\\\"/static/img/Black4.2ffd307.png\\\",\\\"resizable\\\":true,\\\"snappable\\\":true,\\\"zIndex\\\":10,\\\"style\\\":{\\\"width\\\":\\\"223px\\\",\\\"height\\\":\\\"202px\\\",\\\"left\\\":0,\\\"top\\\":0,\\\"rotate\\\":0,\\\"zIndex\\\":10,\\\"transform\\\":\\\" translate(115px, 135px) \\\"}},{\\\"category\\\":\\\"ny\\\",\\\"id\\\":\\\"afbc21eb-e145-42df-b8ea-3e06c264cde9\\\",\\\"image\\\":\\\"/static/img/2.a900bbf.png\\\",\\\"resizable\\\":true,\\\"snappable\\\":true,\\\"zIndex\\\":10,\\\"style\\\":{\\\"width\\\":\\\"455px\\\",\\\"height\\\":\\\"208px\\\",\\\"left\\\":0,\\\"top\\\":0,\\\"rotate\\\":0,\\\"zIndex\\\":100,\\\"transform\\\":\\\" translate(2px, 488px) \\\"}}]\"', '2026-03-17 13:34:10');
INSERT INTO `ai_model` VALUES (8, '123', 'Female', '\"[{\\\"category\\\":\\\"d_model\\\",\\\"id\\\":\\\"6abe0510-d3a4-42af-9822-49e4a3f410e3\\\",\\\"image\\\":\\\"/static/img/a默认.825f962.png\\\",\\\"resizable\\\":true,\\\"snappable\\\":true,\\\"zIndex\\\":1,\\\"style\\\":{\\\"width\\\":\\\"506px\\\",\\\"height\\\":\\\"573px\\\",\\\"left\\\":\\\"50%\\\",\\\"top\\\":\\\"50%\\\",\\\"rotate\\\":0,\\\"zIndex\\\":1,\\\"transform\\\":\\\" translate(-50%, -50%)\\\"}},{\\\"category\\\":\\\"前发a_front\\\",\\\"id\\\":\\\"7e6c0524-3372-4eeb-9c93-19bd5b4252ce\\\",\\\"image\\\":\\\"/static/img/Blondie2.819ac37.png\\\",\\\"resizable\\\":true,\\\"snappable\\\":true,\\\"zIndex\\\":10,\\\"style\\\":{\\\"width\\\":\\\"214px\\\",\\\"height\\\":\\\"376px\\\",\\\"left\\\":0,\\\"top\\\":0,\\\"rotate\\\":0,\\\"zIndex\\\":10,\\\"transform\\\":\\\"translate(290px, 196px)\\\"}},{\\\"category\\\":\\\"ny\\\",\\\"id\\\":\\\"aab430b7-1413-4607-bd1c-dd1d5b647cf8\\\",\\\"image\\\":\\\"/static/img/1.82fe57d.png\\\",\\\"resizable\\\":true,\\\"snappable\\\":true,\\\"zIndex\\\":10,\\\"style\\\":{\\\"width\\\":\\\"234px\\\",\\\"height\\\":\\\"198px\\\",\\\"left\\\":0,\\\"top\\\":0,\\\"rotate\\\":0,\\\"zIndex\\\":10,\\\"transform\\\":\\\"translate(281px, 487px)\\\"}}]\"', '2026-04-15 11:44:22');

-- ----------------------------
-- Table structure for evaluate
-- ----------------------------
DROP TABLE IF EXISTS `evaluate`;
CREATE TABLE `evaluate`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `merchant` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '评分的是哪个商家',
  `username` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '评分用户',
  `score` float(5, 2) NULL DEFAULT NULL COMMENT '评级分数',
  `content` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '评价内容',
  `create_time` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = MyISAM AUTO_INCREMENT = 25 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of evaluate
-- ----------------------------
INSERT INTO `evaluate` VALUES (1, 'B', 'A', 4.00, '很满意', '2025-03-28 07:10:13');
INSERT INTO `evaluate` VALUES (2, '13333333333', '11111111111', 5.00, '成功解决了我的问题', '2025-03-28 08:25:49');
INSERT INTO `evaluate` VALUES (3, '13333333333', '11111111111', 3.50, '还行吧', '2025-03-28 15:01:53');
INSERT INTO `evaluate` VALUES (4, '13333333333', 'maijia', 5.00, '服务态度好', '2025-04-02 10:44:05');
INSERT INTO `evaluate` VALUES (5, 'F', 'A', 9.00, '的的', '2026-04-15 14:16:41');
INSERT INTO `evaluate` VALUES (6, 'F', 'A', 4.00, '啊啊', '2026-04-15 14:16:51');
INSERT INTO `evaluate` VALUES (7, 'F', 'A', 1.00, '水电费', '2026-04-15 14:17:06');
INSERT INTO `evaluate` VALUES (8, 'F', 'C', 8.00, '是', '2026-04-15 14:18:19');
INSERT INTO `evaluate` VALUES (9, 'B', 'C', 1.00, '不好听', '2026-04-15 14:23:08');
INSERT INTO `evaluate` VALUES (10, 'B', 'C', 1.00, '的', '2026-04-15 14:23:17');
INSERT INTO `evaluate` VALUES (11, 'H', '111111', 4.00, '变成', '2026-04-15 15:41:38');
INSERT INTO `evaluate` VALUES (12, 'H', '111111', 5.00, '啊', '2026-04-15 15:41:41');
INSERT INTO `evaluate` VALUES (13, 'H', '111111', 5.00, '是', '2026-04-15 15:41:51');
INSERT INTO `evaluate` VALUES (14, 'I', '111111', 5.00, '不过', '2026-04-15 15:45:07');
INSERT INTO `evaluate` VALUES (15, 'F', '111111', 5.00, '不不不', '2026-04-15 15:50:55');
INSERT INTO `evaluate` VALUES (16, 'H', '111111', 5.00, '呵呵呵', '2026-04-15 15:53:37');
INSERT INTO `evaluate` VALUES (17, 'H', '111111', 5.00, '呵呵呵呵呵', '2026-04-15 15:53:45');
INSERT INTO `evaluate` VALUES (18, 'J', '111111', 10.00, '很棒的体验', '2026-04-16 05:51:14');
INSERT INTO `evaluate` VALUES (19, 'J', '111111', 1.00, '差死了', '2026-04-16 05:51:28');
INSERT INTO `evaluate` VALUES (20, 'B', 'C', 6.00, '变成', '2026-04-16 05:57:35');
INSERT INTO `evaluate` VALUES (21, 'D', 'C', 4.00, '搜索', '2026-04-16 05:57:48');
INSERT INTO `evaluate` VALUES (22, 'K', 'C', 8.00, '不错', '2026-04-16 06:00:43');
INSERT INTO `evaluate` VALUES (23, 'K', '111111', 7.00, '还可以', '2026-04-16 06:01:09');
INSERT INTO `evaluate` VALUES (24, '123', 'C', 10.00, '相当好', '2026-04-16 06:11:32');

-- ----------------------------
-- Table structure for friendships
-- ----------------------------
DROP TABLE IF EXISTS `friendships`;
CREATE TABLE `friendships`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username1` varchar(191) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '用户ID1',
  `username2` varchar(191) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '用户ID2',
  `username1head` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `username2head` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `create_at` timestamp(0) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `endMessage` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '这是用户1给2或者2给1发的最后一条消息 我们一开始都放到redis里面 当断开链接的时候写入数据库',
  `endTime` datetime(0) NULL DEFAULT NULL COMMENT '这是用户1给2或者2给1发的最后一条消息时间 我们一开始都放到redis里面 当断开链接的时候写入数据库',
  `user1unreadnum` int(11) UNSIGNED NULL DEFAULT NULL COMMENT '用户1未读消息数',
  `user2unreadnum` int(11) UNSIGNED NULL DEFAULT NULL COMMENT '用户2未读消息数',
  `is_robot` tinyint(1) NULL DEFAULT NULL COMMENT '0不是机器人 是 真人客服 1 是机器人客服 默认都是机器人 然后如果转人工就变成真人客服',
  `is_role1` tinyint(1) NULL DEFAULT NULL COMMENT '用户1的角色 0管理员(客服) 1卖家 2买家',
  `is_role2` tinyint(1) NULL DEFAULT NULL COMMENT '用户2的角色 0管理员(客服) 1卖家 2买家',
  `goods_id` int(11) NULL DEFAULT NULL COMMENT '咨询问题 就是针对于什么商品的咨询 对于服务寻接客服可以是空值',
  `robot_switch_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP COMMENT '状态切换时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 106 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of friendships
-- ----------------------------
INSERT INTO `friendships` VALUES (85, '111111', 'B', 'https://img.88icon.com/download/jpg/20210107/400b226fbbb6b3d710cf1ceb00add1a1_512_512.jpg!bg', 'http://localhost:8090/uploads/avatar/3648cfba-255d-4d57-ba42-ad3bd12b5b63_1743142386420.jpg', '2026-04-16 18:17:23', '但是东风风神佛挡杀佛师德师风是', '2026-04-16 18:19:32', 2, 0, 0, 2, 1, NULL, '2026-04-16 18:14:20');
INSERT INTO `friendships` VALUES (86, '111111', 'F', 'https://img.88icon.com/download/jpg/20210107/400b226fbbb6b3d710cf1ceb00add1a1_512_512.jpg!bg', 'https://img.88icon.com/download/jpg/20210107/400b226fbbb6b3d710cf1ceb00add1a1_512_512.jpg!bg', '2026-04-16 18:22:58', '上午说我', '2026-04-16 18:28:48', 1, 0, 0, 2, 1, NULL, '2026-04-16 18:23:48');
INSERT INTO `friendships` VALUES (87, 'AA', 'admin', 'https://img.88icon.com/download/jpg/20210107/400b226fbbb6b3d710cf1ceb00add1a1_512_512.jpg!bg', 'http://localhost:8090/uploads/avatar/5f2def54-5cf5-4431-a521-f14d1ea2426f_1743143128884.jpg', '2026-04-16 20:03:29', NULL, NULL, 0, 0, 1, 2, 0, NULL, '2026-04-16 20:03:29');
INSERT INTO `friendships` VALUES (88, 'AA', 'ad', 'https://img.88icon.com/download/jpg/20210107/400b226fbbb6b3d710cf1ceb00add1a1_512_512.jpg!bg', NULL, '2026-04-16 20:03:29', NULL, NULL, 0, 0, 1, 2, 0, NULL, '2026-04-16 20:03:29');
INSERT INTO `friendships` VALUES (89, '123', 'AA', 'https://img.88icon.com/download/jpg/20210107/400b226fbbb6b3d710cf1ceb00add1a1_512_512.jpg!bg', 'http://localhost:8090/uploads/avatar/695723a2-a240-4e89-b56a-bce65edb90e5_1776253593958.jpg', '2026-04-16 20:04:31', NULL, NULL, 0, 0, 1, 2, 1, 48, '2026-04-16 20:04:31');
INSERT INTO `friendships` VALUES (90, 'BB', 'admin', 'https://img.88icon.com/download/jpg/20210107/400b226fbbb6b3d710cf1ceb00add1a1_512_512.jpg!bg', 'http://localhost:8090/uploads/avatar/5f2def54-5cf5-4431-a521-f14d1ea2426f_1743143128884.jpg', '2026-04-16 20:11:51', '非常抱歉给您带来了不好的体验！😔 请问具体是遇到了什么问题呢？比如是商品无法正常使用、功能异常，还是有其他情况？麻烦您详细描述一下，我会尽力帮您解决或提供合适的建议！', '2026-04-16 20:56:44', 0, 4, 1, 1, 0, NULL, '2026-04-16 20:11:51');
INSERT INTO `friendships` VALUES (91, 'BB', 'ad', 'https://img.88icon.com/download/jpg/20210107/400b226fbbb6b3d710cf1ceb00add1a1_512_512.jpg!bg', NULL, '2026-04-16 20:11:51', NULL, NULL, 0, 0, 1, 1, 0, NULL, '2026-04-16 20:11:51');
INSERT INTO `friendships` VALUES (105, 'A', 'B', 'http://localhost:8090/uploads/avatar/031aefe1-da56-4f2d-8829-29fc4ce24ac1_1743121928649.jpg', 'http://localhost:8090/uploads/avatar/3648cfba-255d-4d57-ba42-ad3bd12b5b63_1743142386420.jpg', '2026-04-16 21:48:46', '啊', '2026-04-16 21:49:23', 1, 0, 0, 2, 1, 42, '2026-04-16 21:48:54');

-- ----------------------------
-- Table structure for goods
-- ----------------------------
DROP TABLE IF EXISTS `goods`;
CREATE TABLE `goods`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `merchant` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商家username',
  `date` datetime(0) NULL DEFAULT NULL COMMENT '时间',
  `isList` tinyint(1) NULL DEFAULT NULL COMMENT '是否上架 1 是上架 0 否上架',
  `src` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品图片的链接',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '商品描述 这里存json 要有品牌 品名 每个品名的价格 特点 规格参数 使用场景 和备注',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品名',
  `star` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品综合评分评价 满分10分 超过6分的是精品甄选',
  `evaluate` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '商品评价 评价是个json数组对象 包含 用户评分和用户评价',
  `price` decimal(10, 2) NULL DEFAULT NULL COMMENT '价格',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = MyISAM AUTO_INCREMENT = 50 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of goods
-- ----------------------------
INSERT INTO `goods` VALUES (29, 'B', '2024-12-13 11:16:35', 1, 'https://picsum.photos/200/200?random=9', '{\"brand\": \"PetMaster\", \"productName\": \"全自动猫砂盆PRO\", \"productPrices\": [{\"name\": \"基础版\", \"price\": 999}, {\"name\": \"PRO版\", \"price\": 1299}], \"features\": [\"全自动清理\", \"智能感应\", \"静音设计\", \"大容量\"], \"specifications\": {\"尺寸\": \"50×40×30cm\", \"重量\": \"8.5kg\", \"电源\": \"AC 220V\", \"容量\": \"15L\"}, \"scenes\": [\"家庭宠物护理\", \"多猫家庭\"], \"remarks\": \"30天无忧退换\"}', '全自动猫砂盆PRO', NULL, NULL, 1299.00);
INSERT INTO `goods` VALUES (28, 'B', '2025-03-01 11:16:35', 1, 'http://localhost:8090/uploads/goods/b6e8f30f-7057-4b76-9f9b-d8c4ca2e5867_1743121889192.jpg', '{\"brand\": \"BeautyTech\", \"productName\": \"纳米喷雾美容仪\", \"productPrices\": [{\"name\": \"标准版\", \"price\": 399}, {\"name\": \"豪华版\", \"price\": 462}], \"features\": [\"纳米级喷雾\", \"深层补水\", \"便携设计\", \"3档调节\"], \"specifications\": {\"喷雾粒径\": \"<0.1μm\", \"水箱容量\": \"80ml\", \"充电时间\": \"2小时\", \"续航\": \"3小时\"}, \"scenes\": [\"日常护肤\", \"外出补水\", \"办公室保湿\"], \"remarks\": \"赠送原装收纳袋\"}', '纳米喷雾美容仪1', NULL, NULL, 462.00);
INSERT INTO `goods` VALUES (27, 'E', '2025-02-01 11:16:35', 1, 'https://picsum.photos/200/200?random=7', '{\"brand\": \"SmartLock\", \"productName\": \"WiFi智能门锁\", \"productPrices\": [{\"name\": \"密码版\", \"price\": 699}, {\"name\": \"指纹版\", \"price\": 799}], \"features\": [\"指纹识别\", \"密码开锁\", \"APP控制\", \"防撬报警\"], \"specifications\": {\"锁体类型\": \"标准锁体\", \"指纹容量\": \"100组\", \"电池\": \"8节5号电池\", \"防护等级\": \"IP54\"}, \"scenes\": [\"家庭安防\", \"公寓管理\", \"办公场所\"], \"remarks\": \"免费上门安装\"}', 'WiFi智能门锁(指纹版)', NULL, NULL, 799.00);
INSERT INTO `goods` VALUES (26, 'F', '2024-11-29 11:16:35', 1, 'https://picsum.photos/200/200?random=6', '{\"brand\": \"LeatherArt\", \"productName\": \"小牛皮手提公文包\", \"productPrices\": [{\"name\": \"标准款\", \"price\": 1599}, {\"name\": \"豪华款\", \"price\": 1899}], \"features\": [\"头层小牛皮\", \"手工缝制\", \"多隔层设计\", \"经典商务\"], \"specifications\": {\"材质\": \"进口小牛皮\", \"尺寸\": \"40×30×10cm\", \"重量\": \"1.2kg\", \"颜色\": \"黑色/棕色\"}, \"scenes\": [\"商务会议\", \"日常通勤\", \"差旅出行\"], \"remarks\": \"赠送皮革保养套装\"}', '小牛皮手提公文包', NULL, NULL, 1899.00);
INSERT INTO `goods` VALUES (25, 'D', '2024-08-01 11:16:35', 1, 'https://picsum.photos/200/200?random=5', '{\"brand\": \"GamingPro\", \"productName\": \"RGB电竞鼠标垫\", \"productPrices\": [{\"name\": \"普通款\", \"price\": 99}, {\"name\": \"大尺寸款\", \"price\": 159}], \"features\": [\"RGB灯效\", \"锁边工艺\", \"防水防滑\", \"顺滑表面\"], \"specifications\": {\"尺寸\": \"900×400×4mm\", \"材质\": \"高密度布面\", \"接口\": \"USB\", \"灯光模式\": \"8种\"}, \"scenes\": [\"电竞游戏\", \"办公学习\", \"直播背景\"], \"remarks\": \"支持自定义RGB灯效\"}', 'RGB电竞鼠标垫(900x400mm)', NULL, NULL, 159.00);
INSERT INTO `goods` VALUES (24, 'F', '2025-03-14 11:16:35', 1, 'https://picsum.photos/200/200?random=4', '{\"brand\": \"LeatherArt\", \"productName\": \"牛皮手工编织腰带\", \"productPrices\": [{\"name\": \"经典款\", \"price\": 199}, {\"name\": \"编织款\", \"price\": 289}], \"features\": [\"纯牛皮制作\", \"手工编织\", \"金属扣头\", \"可调节长度\"], \"specifications\": {\"材质\": \"真皮\", \"长度\": \"120cm\", \"宽度\": \"3.5cm\", \"颜色\": \"黑色/棕色\"}, \"scenes\": [\"商务正装\", \"休闲搭配\", \"日常使用\"], \"remarks\": \"支持长度定制\"}', '牛皮手工编织腰带', NULL, NULL, 289.00);
INSERT INTO `goods` VALUES (23, 'D', '2025-02-17 11:16:35', 0, 'https://picsum.photos/200/200?random=3', '{\"brand\": \"SmartHome\", \"productName\": \"智能恒温电水壶\", \"productPrices\": [{\"name\": \"普通款\", \"price\": 129}, {\"name\": \"恒温款\", \"price\": 199}], \"features\": [\"恒温保温\", \"APP控制\", \"多重保护\", \"快速沸腾\"], \"specifications\": {\"容量\": \"1.7L\", \"功率\": \"1800W\", \"温控范围\": \"40-100℃\", \"材质\": \"304不锈钢\"}, \"scenes\": [\"家庭使用\", \"办公室\", \"酒店客房\"], \"remarks\": \"支持12小时预约\"}', '智能恒温电水壶', NULL, NULL, 199.00);
INSERT INTO `goods` VALUES (22, 'F', '2025-01-14 11:16:35', 1, 'https://picsum.photos/200/200?random=2', '{\"brand\": \"CinemaPro\", \"productName\": \"4K HDR智能投影仪\", \"productPrices\": [{\"name\": \"1080P版\", \"price\": 2599}, {\"name\": \"4K HDR版\", \"price\": 3299}], \"features\": [\"4K分辨率\", \"HDR10+\", \"智能系统\", \"自动对焦\"], \"specifications\": {\"分辨率\": \"3840×2160\", \"亮度\": \"2000ANSI流明\", \"系统\": \"Android 9.0\", \"内存\": \"3+32GB\"}, \"scenes\": [\"家庭影院\", \"商务演示\", \"游戏娱乐\"], \"remarks\": \"送3个月影视会员\"}', '4K HDR智能投影仪', NULL, NULL, 3299.00);
INSERT INTO `goods` VALUES (21, 'D', '2024-05-29 11:16:35', 1, 'https://picsum.photos/200/200?random=1', '{\"brand\": \"MechKey\", \"productName\": \"极光机械键盘\", \"productPrices\": [{\"name\": \"红轴\", \"price\": 499}, {\"name\": \"青轴\", \"price\": 599}], \"features\": [\"机械轴体\", \"RGB背光\", \"全键无冲\", \"PBT键帽\"], \"specifications\": {\"轴体\": \"Cherry青轴\", \"按键数\": \"104键\", \"连接\": \"有线+蓝牙\", \"背光\": \"RGB\"}, \"scenes\": [\"游戏电竞\", \"办公打字\", \"程序员编程\"], \"remarks\": \"支持宏编程\"}', '极光机械键盘(青轴)', NULL, NULL, 599.00);
INSERT INTO `goods` VALUES (30, 'H', '2025-01-25 11:16:35', 1, 'https://picsum.photos/200/200?random=10', '{\"brand\": \"SpeedBike\", \"productName\": \"碳纤维公路自行车\", \"productPrices\": [{\"name\": \"入门款\", \"price\": 5999}, {\"name\": \"专业款\", \"price\": 8999}], \"features\": [\"碳纤维车架\", \"禧玛诺套件\", \"碟刹系统\", \"空气动力学\"], \"specifications\": {\"车架材质\": \"碳纤维\", \"套件\": \"Shimano 105\", \"刹车\": \"液压碟刹\", \"重量\": \"8.5kg\"}, \"scenes\": [\"公路骑行\", \"竞赛训练\", \"健身运动\"], \"remarks\": \"送专业安装调试\"}', '碳纤维公路自行车', NULL, NULL, 8999.00);
INSERT INTO `goods` VALUES (31, 'H', '2025-02-10 11:16:35', 1, 'https://picsum.photos/200/200?random=11', '{\"brand\": \"ErgoChair\", \"productName\": \"人体工学电脑椅\", \"productPrices\": [{\"name\": \"普通款\", \"price\": 899}, {\"name\": \"豪华款\", \"price\": 1599}], \"features\": [\"人体工学设计\", \"可调节腰靠\", \"透气网布\", \"静音滚轮\"], \"specifications\": {\"承重\": \"150kg\", \"材质\": \"透气网布\", \"升降范围\": \"45-55cm\", \"颜色\": \"黑色/灰色\"}, \"scenes\": [\"办公学习\", \"电竞游戏\", \"居家使用\"], \"remarks\": \"送货上门安装\"}', '人体工学电脑椅', NULL, NULL, 1599.00);
INSERT INTO `goods` VALUES (32, 'H', '2024-04-01 11:16:35', 1, 'https://picsum.photos/200/200?random=12', '{\"brand\": \"JewelArt\", \"productName\": \"18K金珍珠耳坠\", \"productPrices\": [{\"name\": \"单珠款\", \"price\": 1999}, {\"name\": \"双珠款\", \"price\": 2999}], \"features\": [\"18K金材质\", \"天然珍珠\", \"精致工艺\", \"优雅设计\"], \"specifications\": {\"材质\": \"18K金\", \"珍珠直径\": \"8-9mm\", \"重量\": \"3.2g\", \"尺寸\": \"2×1cm\"}, \"scenes\": [\"宴会聚会\", \"日常佩戴\", \"礼物赠送\"], \"remarks\": \"附赠鉴定证书\"}', '18K金珍珠耳坠', NULL, NULL, 2999.00);
INSERT INTO `goods` VALUES (33, 'I', '2025-03-13 11:16:35', 0, 'https://picsum.photos/200/200?random=13', '{\"brand\": \"CoffeeMaster\", \"productName\": \"意式半自动咖啡机\", \"productPrices\": [{\"name\": \"家用款\", \"price\": 2690}, {\"name\": \"商用款\", \"price\": 3690}], \"features\": [\"20Bar压力\", \"蒸汽打奶\", \"PID控温\", \"不锈钢机身\"], \"specifications\": {\"压力\": \"20Bar\", \"水箱\": \"2.5L\", \"功率\": \"1500W\", \"尺寸\": \"30×40×35cm\"}, \"scenes\": [\"家庭咖啡\", \"小型咖啡馆\", \"办公室\"], \"remarks\": \"赠送咖啡豆和清洁套装\"}', '意式半自动咖啡机', NULL, NULL, 3690.00);
INSERT INTO `goods` VALUES (34, 'I', '2024-12-14 11:16:35', 1, 'https://picsum.photos/200/200?random=14', '{\"brand\": \"FoldPhone\", \"productName\": \"折叠屏智能手机\", \"productPrices\": [{\"name\": \"256GB\", \"price\": 7999}, {\"name\": \"512GB\", \"price\": 8999}], \"features\": [\"可折叠屏幕\", \"5G网络\", \"多摄像头\", \"大容量电池\"], \"specifications\": {\"屏幕\": \"7.6寸折叠屏\", \"处理器\": \"骁龙8Gen2\", \"内存\": \"12+512GB\", \"电池\": \"4800mAh\"}, \"scenes\": [\"商务办公\", \"影音娱乐\", \"移动办公\"], \"remarks\": \"碎屏险一年\"}', '折叠屏智能手机', NULL, NULL, 8999.00);
INSERT INTO `goods` VALUES (35, 'I', '2024-12-05 11:16:35', 1, 'https://picsum.photos/200/200?random=15', '{\"brand\": \"KitchenPro\", \"productName\": \"德国精钢刀具八件套\", \"productPrices\": [{\"name\": \"基础套\", \"price\": 399}, {\"name\": \"精钢套\", \"price\": 599}], \"features\": [\"德国钢材\", \"锋利耐用\", \"人体工学手柄\", \"全套配备\"], \"specifications\": {\"材质\": \"高碳不锈钢\", \"硬度\": \"58HRC\", \"包含\": \"8件刀具\", \"刀座\": \"实木刀座\"}, \"scenes\": [\"家庭厨房\", \"专业厨房\", \"礼物赠送\"], \"remarks\": \"永久免费磨刀\"}', '德国精钢刀具八件套', NULL, NULL, 599.00);
INSERT INTO `goods` VALUES (36, 'I', '2025-01-05 11:16:35', 1, 'https://picsum.photos/200/200?random=16', '{\"brand\": \"HealthTech\", \"productName\": \"智能体脂秤\", \"productPrices\": [{\"name\": \"普通款\", \"price\": 99}, {\"name\": \"蓝牙版\", \"price\": 199}], \"features\": [\"蓝牙连接\", \"13项体脂数据\", \"APP同步\", \"高精度传感器\"], \"specifications\": {\"测量项目\": \"13项\", \"蓝牙版本\": \"5.0\", \"承重\": \"150kg\", \"电池\": \"CR2032×4\"}, \"scenes\": [\"家庭健康管理\", \"健身监测\", \"体重管理\"], \"remarks\": \"赠送APP会员一年\"}', '智能体脂秤(蓝牙版)', NULL, NULL, 199.00);
INSERT INTO `goods` VALUES (37, 'D', '2025-01-15 11:16:35', 0, 'https://picsum.photos/200/200?random=17', '{\"brand\": \"PhotoPro\", \"productName\": \"全画幅微单相机\", \"productPrices\": [{\"name\": \"单机身\", \"price\": 12999}, {\"name\": \"套机\", \"price\": 16999}], \"features\": [\"全画幅传感器\", \"4K视频\", \"高速连拍\", \"五轴防抖\"], \"specifications\": {\"传感器\": \"全画幅CMOS\", \"像素\": \"2400万\", \"对焦\": \"425点\", \"视频\": \"4K/60p\"}, \"scenes\": [\"专业摄影\", \"视频创作\", \"旅行记录\"], \"remarks\": \"赠送相机包和存储卡\"}', '全画幅微单相机', NULL, NULL, 16999.00);
INSERT INTO `goods` VALUES (38, 'J', '2025-02-02 11:16:35', 1, 'https://picsum.photos/200/200?random=18', '{\"brand\": \"TimeLux\", \"productName\": \"机械腕表\", \"productPrices\": [{\"name\": \"钢带款\", \"price\": 4999}, {\"name\": \"蓝宝石款\", \"price\": 5999}], \"features\": [\"自动机械机芯\", \"蓝宝石镜面\", \"50米防水\", \"夜光指针\"], \"specifications\": {\"机芯\": \"自动机械\", \"镜面\": \"蓝宝石\", \"表带\": \"不锈钢\", \"直径\": \"42mm\"}, \"scenes\": [\"商务场合\", \"日常佩戴\", \"收藏礼物\"], \"remarks\": \"全球联保三年\"}', '机械腕表(蓝宝石镜面)', NULL, NULL, 5999.00);
INSERT INTO `goods` VALUES (39, 'K', '2025-02-21 11:16:35', 1, 'https://picsum.photos/200/200?random=19', '{\"brand\": \"AudioPro\", \"productName\": \"Hi-Fi书架音箱\", \"productPrices\": [{\"name\": \"单只\", \"price\": 2499}, {\"name\": \"一对\", \"price\": 4999}], \"features\": [\"Hi-Fi音质\", \"木质箱体\", \"丝膜高音\", \"发烧级分频\"], \"specifications\": {\"功率\": \"60W\", \"阻抗\": \"8Ω\", \"频响\": \"50-20kHz\", \"尺寸\": \"18×30×25cm\"}, \"scenes\": [\"家庭影音\", \"书房听音\", \"工作室监听\"], \"remarks\": \"赠送发烧音频线\"}', 'Hi-Fi书架音箱', '7.5', '[{\"rating\":8.0,\"comment\":\"不错\",\"time\":1776319242952,\"username\":\"C\"},{\"rating\":7.0,\"comment\":\"还可以\",\"time\":1776319268979,\"username\":\"111111\"}]', 4999.00);
INSERT INTO `goods` VALUES (40, 'J', '2024-11-26 11:16:35', 1, 'https://picsum.photos/200/200?random=20', '{\"brand\": \"TravelPro\", \"productName\": \"航空铝镁合金行李箱\", \"productPrices\": [{\"name\": \"20寸\", \"price\": 699}, {\"name\": \"28寸\", \"price\": 899}], \"features\": [\"航空铝镁合金\", \"TSA海关锁\", \"万向静音轮\", \"防水面料\"], \"specifications\": {\"材质\": \"铝镁合金\", \"尺寸\": \"28寸\", \"重量\": \"4.5kg\", \"容量\": \"100L\"}, \"scenes\": [\"差旅出行\", \"留学搬家\", \"长途旅行\"], \"remarks\": \"5年质保\"}', '航空铝镁合金行李箱', NULL, NULL, 899.00);
INSERT INTO `goods` VALUES (43, '13333333333', '2025-03-28 08:20:14', 1, 'http://localhost:8090/uploads/goods/8660c7eb-9b17-46c2-a386-7fc435e9eb16_1743150012449.jpg', '{\"brand\": \"青岛啤酒\", \"productName\": \"纯正青岛啤酒\", \"productPrices\": [{\"name\": \"330ml单瓶\", \"price\": 4}, {\"name\": \"500ml单瓶\", \"price\": 6}], \"features\": [\"纯麦酿造\", \"口感醇厚\", \"新鲜日期\", \"经典口味\"], \"specifications\": {\"规格\": \"500ml\", \"酒精度\": \"≥4.0%vol\", \"原料\": \"水、麦芽、啤酒花\", \"保质期\": \"12个月\"}, \"scenes\": [\"聚会宴请\", \"家庭饮用\", \"餐饮酒店\"], \"remarks\": \"整箱购买更优惠\"}', '新纯正青岛啤酒', NULL, NULL, 4.00);
INSERT INTO `goods` VALUES (42, 'B', '2025-03-27 11:40:54', 1, 'http://localhost:8090/uploads/goods/309e3a4b-14ff-48cc-8e30-43b5a2d75f79_1743121883787.jpg', '{\"brand\": \"Zi\", \"productName\": \"Zi行车\", \"productPrices\": [{\"name\": \"基础款\", \"price\": 8}, {\"name\": \"升级款\", \"price\": 10}], \"features\": [\"轻便设计\", \"可折叠\", \"多色可选\", \"简易安装\"], \"specifications\": {\"材质\": \"铝合金\", \"尺寸\": \"20寸\", \"重量\": \"8kg\", \"颜色\": \"红/蓝/黑\"}, \"scenes\": [\"短途通勤\", \"校园代步\", \"休闲骑行\"], \"remarks\": \"赠送工具包\"}', 'Zi行车', NULL, NULL, 10.00);
INSERT INTO `goods` VALUES (44, '13333333333', '2025-03-28 08:20:35', 1, 'http://localhost:8090/uploads/goods/d02033e7-3509-4a89-8658-5c4e71a92b0b_1743150034483.jpg', '{\"brand\": \"青岛啤酒\", \"productName\": \"滋味青岛啤酒\", \"productPrices\": [{\"name\": \"330ml单瓶\", \"price\": 6}, {\"name\": \"500ml单瓶\", \"price\": 10}], \"features\": [\"新配方\", \"口感清爽\", \"泡沫丰富\", \"低温锁鲜\"], \"specifications\": {\"规格\": \"500ml\", \"酒精度\": \"≥3.6%vol\", \"原料\": \"水、麦芽、大米、啤酒花\", \"保质期\": \"12个月\"}, \"scenes\": [\"聚会宴请\", \"家庭饮用\", \"餐饮酒店\"], \"remarks\": \"新配方新体验\"}', '新滋味青岛啤酒', NULL, NULL, 10.00);
INSERT INTO `goods` VALUES (45, '13333333333', '2025-03-28 15:03:05', 1, 'http://localhost:8090/uploads/goods/03cf4949-0db5-4674-a71f-9e0173b9e9fa_1743174175307.jpg', '{\"brand\": \"青岛啤酒\", \"productName\": \"啤酒新款\", \"productPrices\": [{\"name\": \"330ml单瓶\", \"price\": 8}, {\"name\": \"500ml单瓶\", \"price\": 15}], \"features\": [\"新款设计\", \"清爽口感\", \"果香风味\", \"易拉罐装\"], \"specifications\": {\"规格\": \"500ml\", \"酒精度\": \"≥4.2%vol\", \"原料\": \"水、麦芽、啤酒花、酵母\", \"保质期\": \"12个月\"}, \"scenes\": [\"聚会宴请\", \"家庭饮用\", \"节日礼品\"], \"remarks\": \"新款上市特惠\"}', '啤酒新款', NULL, NULL, 15.00);
INSERT INTO `goods` VALUES (46, 'maijia', '2025-03-31 11:12:54', 1, 'http://localhost:8090/uploads/goods/13fe9cd5-f4af-4481-b72c-64b7d36b6710_1743419572727.jpg', '{\"brand\": \"青岛啤酒\", \"productName\": \"青岛啤酒\", \"productPrices\": [{\"name\": \"330ml单瓶\", \"price\": 4}, {\"name\": \"500ml单瓶\", \"price\": 5}], \"features\": [\"经典口味\", \"麦香浓郁\", \"泡沫细腻\", \"清爽解渴\"], \"specifications\": {\"规格\": \"500ml\", \"酒精度\": \"≥4.0%vol\", \"原料\": \"水、麦芽、大米、啤酒花\", \"保质期\": \"12个月\"}, \"scenes\": [\"日常饮用\", \"朋友聚会\", \"佐餐搭配\"], \"remarks\": \"经典畅销款\"}', '青岛啤酒', NULL, NULL, 5.00);
INSERT INTO `goods` VALUES (47, '123', '2026-04-15 10:07:36', 1, 'http://localhost:8090/uploads/goods/b94bc3c0-1539-4880-aeed-a8434cb4a991_1776247651272.jpg', '{\"brand\": \"未命名\", \"productName\": \"111\", \"productPrices\": [{\"name\": \"标准装\", \"price\": 3}, {\"name\": \"大包装\", \"price\": 4}], \"features\": [\"性价比高\", \"实用性强\", \"基础功能\"], \"specifications\": {\"材质\": \"通用\", \"尺寸\": \"标准\", \"重量\": \"常规\", \"颜色\": \"通用色\"}, \"scenes\": [\"日常使用\", \"基础需求\"], \"remarks\": \"新品上架\"}', '111', NULL, NULL, 4.00);
INSERT INTO `goods` VALUES (48, '123', '2026-04-15 14:27:13', 1, 'http://localhost:8090/uploads/goods/843268cd-3709-494a-b3d9-0d6ce623c313_1776263182507.jpg', '{\"brand\":\"大牌子\",\"productName\":\"劳克斯\",\"productPrices\":[{\"name\":\"新品尝鲜\",\"price\":10}],\"features\":[\"大\"],\"specifications\":{\"材质\":\"瓷器\"},\"scenes\":[\"喝水\"],\"remark\":\"\"}', '杯子', '10', '[{\"rating\":10.0,\"comment\":\"相当好\",\"time\":1776319891785,\"username\":\"C\"}]', 28.00);
INSERT INTO `goods` VALUES (49, 'BB', '2026-04-16 12:49:08', 1, 'http://localhost:8090/uploads/goods/c3aa7649-56ee-4bd1-bc74-861202e445ff_1776343671849.jpg', '{\"brand\":\"A\",\"productName\":\"好安全\",\"productPrices\":[{\"name\":\"38码\",\"price\":65},{\"name\":\"40码\",\"price\":79}],\"features\":[\"大\"],\"specifications\":{\"材质\":\"皮革\",\"码数\":\"30-40\"},\"scenes\":[\"走路\",\"跳舞\"],\"remark\":\"没有备注\"}', '鞋子', NULL, NULL, 65.00);

-- ----------------------------
-- Table structure for messages
-- ----------------------------
DROP TABLE IF EXISTS `messages`;
CREATE TABLE `messages`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `sender_username` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '发送者username',
  `receiver_username` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '接收者username',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '消息内容（文本或加密后的多媒体路径）',
  `send_time` timestamp(0) NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发送时间',
  `is_send` tinyint(1) NULL DEFAULT 1 COMMENT '1=发送方记录，0=接收方记录',
  `delete_status` tinyint(1) NULL DEFAULT 0 COMMENT '0=未删除，1=发送方删除，2=接收方删除',
  `is_active` tinyint(1) NULL DEFAULT NULL COMMENT '接受者是否在线',
  `goods_id` int(11) NULL DEFAULT NULL COMMENT '商品ID 咨询的商品ID 可以是空',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `sender_id`(`sender_username`(250)) USING BTREE,
  INDEX `receiver_id`(`receiver_username`(250)) USING BTREE
) ENGINE = MyISAM AUTO_INCREMENT = 898 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of messages
-- ----------------------------
INSERT INTO `messages` VALUES (796, '111111', 'F', '我想咨询一下', '2026-04-16 10:24:45', 1, 0, 1, NULL);
INSERT INTO `messages` VALUES (795, 'F', '111111', '你好 这里是人工服务', '2026-04-16 10:24:24', 1, 0, 1, NULL);
INSERT INTO `messages` VALUES (794, '111111', 'F', '你好', '2026-04-16 10:24:08', 1, 0, 1, NULL);
INSERT INTO `messages` VALUES (793, 'F', '111111', '您好！欢迎光临本店，有什么可以为您服务的吗？', '2026-04-16 10:23:04', 1, 0, 1, NULL);
INSERT INTO `messages` VALUES (792, '111111', 'F', '你好', '2026-04-16 10:23:04', 1, 0, 1, NULL);
INSERT INTO `messages` VALUES (791, 'B', '111111', '但是东风风神佛挡杀佛师德师风是', '2026-04-16 10:19:32', 1, 0, 1, NULL);
INSERT INTO `messages` VALUES (790, '111111', 'B', '头疼', '2026-04-16 10:17:37', 1, 0, 1, NULL);
INSERT INTO `messages` VALUES (789, 'B', '111111', '可以的', '2026-04-16 10:14:35', 1, 0, 1, NULL);
INSERT INTO `messages` VALUES (788, '111111', 'B', '你好', '2026-04-16 10:14:24', 1, 0, 1, NULL);
INSERT INTO `messages` VALUES (787, '111111', 'B', '非法', '2026-04-16 10:13:58', 1, 0, 1, NULL);
INSERT INTO `messages` VALUES (797, '111111', 'F', '上午说我', '2026-04-16 10:28:48', 1, 0, 1, NULL);
INSERT INTO `messages` VALUES (893, 'A', 'B', '减伤', '2026-04-16 13:48:49', 1, 0, 1, NULL);
INSERT INTO `messages` VALUES (894, 'B', 'A', '您好，关于您提到的“减伤”，我这边没有查询到相关的商品或服务信息。请问您是想咨询商品折扣、优惠活动，还是其他方面的问题呢？我可以为您详细解答。', '2026-04-16 13:48:49', 1, 0, 1, NULL);
INSERT INTO `messages` VALUES (895, 'A', 'B', '啊啊啊', '2026-04-16 13:49:07', 1, 0, 1, NULL);
INSERT INTO `messages` VALUES (896, 'A', 'B', '就看你牛的', '2026-04-16 13:49:21', 1, 0, 1, NULL);
INSERT INTO `messages` VALUES (897, 'B', 'A', '啊', '2026-04-16 13:49:23', 1, 0, 1, NULL);
INSERT INTO `messages` VALUES (820, 'BB', 'admin', '不好用了', '2026-04-16 12:56:41', 1, 0, 1, NULL);
INSERT INTO `messages` VALUES (821, 'admin', 'BB', '非常抱歉给您带来了不好的体验！😔 请问具体是遇到了什么问题呢？比如是商品无法正常使用、功能异常，还是有其他情况？麻烦您详细描述一下，我会尽力帮您解决或提供合适的建议！', '2026-04-16 12:56:41', 1, 0, 1, NULL);
INSERT INTO `messages` VALUES (818, 'BB', 'admin', '在吗', '2026-04-16 12:56:31', 1, 0, 1, NULL);
INSERT INTO `messages` VALUES (819, 'admin', 'BB', '在的！请问有什么可以帮您？😊', '2026-04-16 12:56:31', 1, 0, 1, NULL);

-- ----------------------------
-- Table structure for reply
-- ----------------------------
DROP TABLE IF EXISTS `reply`;
CREATE TABLE `reply`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `receiver` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '接受的商铺（发送给信息的商铺）',
  `answer` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '回答',
  `question` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '问题',
  `prority` int(11) NULL DEFAULT NULL COMMENT '优先级 默认不填',
  PRIMARY KEY (`id`) USING BTREE,
  FULLTEXT INDEX `idx_question_ft`(`question`) WITH PARSER `ngram`,
  FULLTEXT INDEX `ft_index`(`question`) WITH PARSER `ngram`
) ENGINE = InnoDB AUTO_INCREMENT = 70 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Records of reply
-- ----------------------------
INSERT INTO `reply` VALUES (1, 'E', '商品未拆封，7天内可凭小票退货。', '退货需要什么条件？', NULL);
INSERT INTO `reply` VALUES (2, 'E', '登录官网或店内查询手机号关联积分。', '如何查询会员积分？', NULL);
INSERT INTO `reply` VALUES (3, 'E', '24小时全天候营业', '每天的营业时间是？', NULL);
INSERT INTO `reply` VALUES (4, 'E', '签收7日内发现印刷问题可退换', '书籍损坏如何退换？', NULL);
INSERT INTO `reply` VALUES (5, 'E', '提供5款无咖啡因咖啡和茶饮', '有无咖啡因饮品吗？', NULL);
INSERT INTO `reply` VALUES (6, 'E', '试用装仅供体验不单独售卖', '试用装可以单独购买吗？', NULL);
INSERT INTO `reply` VALUES (7, 'E', '大家电享3年整机质保服务', '保修期多久？', NULL);
INSERT INTO `reply` VALUES (8, '生鲜市场', '每日早上8点更新库存', '商品缺货何时补货？', NULL);
INSERT INTO `reply` VALUES (9, '健身器材馆', '购买满2000元提供免费安装', '器械包安装吗？', NULL);
INSERT INTO `reply` VALUES (10, '宠物用品店', '食品类商品开封后不可退换', '猫粮开封后能退吗？', NULL);
INSERT INTO `reply` VALUES (11, 'B', '下单后30分钟内可联系客服修改', '订单修改截止时间？', 0);
INSERT INTO `reply` VALUES (12, 'F', '根据人体工学大数据推荐，准确率98%', '尺码推荐准确吗？', 2);
INSERT INTO `reply` VALUES (13, 'D', '商品详情页底部有二维码扫码观看', '安装视频在哪查看？', 0);
INSERT INTO `reply` VALUES (14, 'B', '下单时选择以旧换新选项，快递员上门取旧机', '以旧换新流程？', 1);
INSERT INTO `reply` VALUES (15, 'F', '预售结束后3个工作日内发出', '预售商品多久发货？', 0);
INSERT INTO `reply` VALUES (16, 'D', '满3件不同品类商品自动享9折', '组合购买有优惠吗？', 0);
INSERT INTO `reply` VALUES (18, 'maijia', '质量问题本店承担，非质量问题客户自理', '退货运费谁承担？', 0);
INSERT INTO `reply` VALUES (19, 'D', '详情页可下载SGS材质认证报告', '商品材质证明？', 1);
INSERT INTO `reply` VALUES (20, 'B', '电压和保修政策不同，功能一致', '海外版有何区别？', 0);
INSERT INTO `reply` VALUES (21, 'F', '采用母婴A类面料，通过过敏原测试', '过敏体质能穿吗？', 2);
INSERT INTO `reply` VALUES (22, 'D', '签收时拍照并拒收，联系客服补发', '破损件怎么处理？', 0);
INSERT INTO `reply` VALUES (23, 'B', '通过学信网在线验证享受9折', '学生优惠怎么认证？', 1);
INSERT INTO `reply` VALUES (24, 'F', '定制商品不支持无理由退换', '定制商品退换政策？', 0);
INSERT INTO `reply` VALUES (25, 'D', '每10分钟更新一次库存数据', '库存同步频率？', 0);
INSERT INTO `reply` VALUES (26, 'B', '签收48小时内拍照反馈补发', '赠品漏发怎么办？', 0);
INSERT INTO `reply` VALUES (27, 'F', '内侧缝线处或领口内侧', '水洗标位置在哪？', 0);
INSERT INTO `reply` VALUES (28, 'D', '通过ISO14001环境管理体系认证', '环保认证有哪些？', 1);
INSERT INTO `reply` VALUES (29, 'maijia', '联系400-888-xxxx获取批量采购价', '企业采购通道？', 2);
INSERT INTO `reply` VALUES (30, 'F', '不可退但可抵扣尾款', '预售定金可退吗？', 0);
INSERT INTO `reply` VALUES (31, 'D', '包含螺丝包和安装工具', '安装配件包含哪些？', 0);
INSERT INTO `reply` VALUES (32, 'B', '签收后3个工作日内发至邮箱', '电子发票何时发送？', 0);
INSERT INTO `reply` VALUES (33, 'F', '提供自然光实拍图可申请退换', '色差严重怎么办？', 1);
INSERT INTO `reply` VALUES (34, 'D', '联系客服提供SN码补寄', '保修卡怎么补办？', 0);
INSERT INTO `reply` VALUES (35, 'B', '6期免息，12期费率3%', '分期付款手续费？', 0);
INSERT INTO `reply` VALUES (36, 'F', '100抵150，尾款再享9折', '预售定金膨胀规则？', 3);
INSERT INTO `reply` VALUES (37, 'D', '自签收次日开始计算', '质保期如何计算？', 0);
INSERT INTO `reply` VALUES (38, 'B', '通常需要3-5个工作日', '海外购清关时长？', 0);
INSERT INTO `reply` VALUES (39, 'maijia', '不同预售批次商品分开发货', '预售商品能合并发货吗？', 0);
INSERT INTO `reply` VALUES (40, 'D', '联系客服生成差价链接支付', '补差价怎么操作？', 1);
INSERT INTO `reply` VALUES (41, 'B', '提供身份证和发票在线申请', '节能补贴如何申请？', 2);
INSERT INTO `reply` VALUES (42, 'F', '付尾款时修改收货地址', '预售商品改地址？', 0);
INSERT INTO `reply` VALUES (43, 'D', '正常使用下的功能故障', '质保范围包含哪些？', 0);
INSERT INTO `reply` VALUES (44, 'B', '享受同等保修但无退换服务', '样机购买注意事项？', 1);
INSERT INTO `reply` VALUES (45, 'F', '需在7日内完成尾款支付', '预售尾款支付时限？', 0);
INSERT INTO `reply` VALUES (46, 'maijia', '全国地级市以上城区覆盖', '安装服务覆盖地区？', 0);
INSERT INTO `reply` VALUES (47, 'B', '可开增值税专用发票', '企业采购开发票？', 0);
INSERT INTO `reply` VALUES (48, 'F', '享受30天价保服务', '预售商品保价吗？', 1);
INSERT INTO `reply` VALUES (49, 'maijia', '详情页可下载CMA检测报告', '商品检测报告？', 0);
INSERT INTO `reply` VALUES (50, 'B', '根据型号和', '以旧换', 2);
INSERT INTO `reply` VALUES (51, 'maijia', '不可退但可转让订单', '预售商品能退定金吗？', 0);
INSERT INTO `reply` VALUES (52, 'maijia', '签收后系统自动发送预约链接', '安装预约方式？', 0);
INSERT INTO `reply` VALUES (53, 'B', '包含主要部件延保1年', '延保服务范围？', 1);
INSERT INTO `reply` VALUES (54, 'F', '需取消订单重新预定', '预售商品换款式？', 0);
INSERT INTO `reply` VALUES (55, 'maijiaD', '详情页可查看FSC认证', '环保材料证明？', 0);
INSERT INTO `reply` VALUES (56, 'B', '配件齐全且全新未使用', '样机配件齐全吗？', 0);
INSERT INTO `reply` VALUES (57, 'F', '需联系客服后台修改', '预售商品改尺码？', 1);
INSERT INTO `reply` VALUES (58, 'maijia', '收到商品后3个工作日内', '质保期维修时长？', 0);
INSERT INTO `reply` VALUES (59, 'B', '5台起享受批发价', '企业采购最低起订量？', 0);
INSERT INTO `reply` VALUES (60, 'F', '按支付顺序陆续发货', '预售商品提前发货？', 2);
INSERT INTO `reply` VALUES (61, 'B', '涵盖整机主要部件三年保修', '延保服务范围', NULL);
INSERT INTO `reply` VALUES (62, 'B', '包括主板、屏幕、电池等核心组件', '延保覆盖哪些部件', NULL);
INSERT INTO `reply` VALUES (64, 'B', '涵盖整机主要部件三年保修', '延保服务范围', NULL);
INSERT INTO `reply` VALUES (65, '13333333333', '商品未拆封，7天内可凭小票退货。', '退货需要什么条件？', 1);
INSERT INTO `reply` VALUES (66, '13333333333', '登录官网或店内查询手机号关联积分。', '如何查询会员积分？', 0);
INSERT INTO `reply` VALUES (67, '13333333333', '试用装仅供体验不单独售卖', '试用装可以单独购买吗？', 0);
INSERT INTO `reply` VALUES (68, '13333333333', '20元买会员卡就可以', '会员积分怎么购买', 0);
INSERT INTO `reply` VALUES (69, 'maijia', '商品未拆封，7天内可凭小票退货。', '退货需要什么条件？', 0);

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `nick` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `head` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '头像地址',
  `logintime` datetime(0) NULL DEFAULT NULL,
  `role` int(255) NULL DEFAULT NULL COMMENT '角色   0管理员(客服) 1卖家 2买家',
  `perms` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '权限',
  `is_robot` tinyint(1) NULL DEFAULT 0 COMMENT '是否是机器人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uniq_username`(`username`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 23 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES (1, '13383331230', 'aMv2neSKwelbxMp3L5ly_g==', 'eer', NULL, '2025-03-14 06:16:17', 2, NULL, 0);
INSERT INTO `user` VALUES (4, '123564', '74be16979710d4c4e7c6647856088456', '用户', NULL, '2025-03-14 06:50:32', 2, NULL, 0);
INSERT INTO `user` VALUES (5, 'A', '74be16979710d4c4e7c6647856088456', 'aa ', 'http://localhost:8090/uploads/avatar/031aefe1-da56-4f2d-8829-29fc4ce24ac1_1743121928649.jpg', '2025-03-15 06:45:01', 2, NULL, 0);
INSERT INTO `user` VALUES (6, 'B', '74be16979710d4c4e7c6647856088456', '心得', 'http://localhost:8090/uploads/avatar/3648cfba-255d-4d57-ba42-ad3bd12b5b63_1743142386420.jpg', '2025-03-15 09:22:34', 1, NULL, 0);
INSERT INTO `user` VALUES (7, 'C', '74be16979710d4c4e7c6647856088456', 'C', 'https://img.88icon.com/download/jpg/20210107/400b226fbbb6b3d710cf1ceb00add1a1_512_512.jpg!bg', '2025-03-17 04:54:22', 2, NULL, 0);
INSERT INTO `user` VALUES (8, 'D', '74be16979710d4c4e7c6647856088456', '好的商家', 'https://img.88icon.com/download/jpg/20210107/400b226fbbb6b3d710cf1ceb00add1a1_512_512.jpg!bg', '2025-03-21 02:50:24', 1, NULL, 0);
INSERT INTO `user` VALUES (9, 'F', '74be16979710d4c4e7c6647856088456', '好的商家', 'https://img.88icon.com/download/jpg/20210107/400b226fbbb6b3d710cf1ceb00add1a1_512_512.jpg!bg', '2025-03-21 03:08:50', 1, NULL, 0);
INSERT INTO `user` VALUES (10, 'admin', '74be16979710d4c4e7c6647856088456', '客服1', 'http://localhost:8090/uploads/avatar/5f2def54-5cf5-4431-a521-f14d1ea2426f_1743143128884.jpg', NULL, 0, NULL, 0);
INSERT INTO `user` VALUES (11, 'ad', '', '客服2', NULL, NULL, 0, NULL, 0);
INSERT INTO `user` VALUES (12, 'G', '74be16979710d4c4e7c6647856088456', '大的商户', 'https://img.88icon.com/download/jpg/20210107/400b226fbbb6b3d710cf1ceb00add1a1_512_512.jpg!bg', '2025-03-24 06:47:24', 1, NULL, 0);
INSERT INTO `user` VALUES (13, 'H', '74be16979710d4c4e7c6647856088456', '好嗨哟', 'https://img.88icon.com/download/jpg/20210107/400b226fbbb6b3d710cf1ceb00add1a1_512_512.jpg!bg', '2025-03-28 06:24:48', 2, NULL, 0);
INSERT INTO `user` VALUES (14, '13333333333', '74be16979710d4c4e7c6647856088456', '青岛啤酒官方旗舰店', 'http://localhost:8090/uploads/avatar/7600589c-dac4-4d68-ab1a-c0c5e4979ef5_1743150314560.jpg', '2025-03-28 08:08:16', 1, NULL, 0);
INSERT INTO `user` VALUES (15, '11111111111', '74be16979710d4c4e7c6647856088456', '星期五', 'http://localhost:8090/uploads/avatar/65fbd880-58ec-4352-9f11-95895812a7d4_1743150407481.jpg', '2025-03-28 08:09:22', 2, NULL, 0);
INSERT INTO `user` VALUES (16, 'maijia', '74be16979710d4c4e7c6647856088456', '测试买家', 'https://img.88icon.com/download/jpg/20210107/400b226fbbb6b3d710cf1ceb00add1a1_512_512.jpg!bg', '2025-03-31 11:09:23', 2, NULL, 0);
INSERT INTO `user` VALUES (17, '111222', '74be16979710d4c4e7c6647856088456', '是', 'https://img.88icon.com/download/jpg/20210107/400b226fbbb6b3d710cf1ceb00add1a1_512_512.jpg!bg', '2026-04-15 07:20:22', 2, NULL, 0);
INSERT INTO `user` VALUES (18, '111111', '74be16979710d4c4e7c6647856088456', '11', 'https://img.88icon.com/download/jpg/20210107/400b226fbbb6b3d710cf1ceb00add1a1_512_512.jpg!bg', '2026-04-15 07:43:10', 2, NULL, 0);
INSERT INTO `user` VALUES (19, '123456', '74be16979710d4c4e7c6647856088456', '马努', 'https://img.88icon.com/download/jpg/20210107/400b226fbbb6b3d710cf1ceb00add1a1_512_512.jpg!bg', '2026-04-15 08:00:21', 2, NULL, 0);
INSERT INTO `user` VALUES (20, '123', '74be16979710d4c4e7c6647856088456', '你们东西', 'http://localhost:8090/uploads/avatar/695723a2-a240-4e89-b56a-bce65edb90e5_1776253593958.jpg', '2026-04-15 09:32:48', 1, NULL, 0);
INSERT INTO `user` VALUES (21, 'AA', '74be16979710d4c4e7c6647856088456', 'AA', 'https://img.88icon.com/download/jpg/20210107/400b226fbbb6b3d710cf1ceb00add1a1_512_512.jpg!bg', '2026-04-16 12:03:30', 2, NULL, 0);
INSERT INTO `user` VALUES (22, 'BB', '74be16979710d4c4e7c6647856088456', 'BB', 'https://img.88icon.com/download/jpg/20210107/400b226fbbb6b3d710cf1ceb00add1a1_512_512.jpg!bg', '2026-04-16 12:11:51', 1, NULL, 0);

-- ----------------------------
-- Event structure for auto_reset_robot_status
-- ----------------------------
DROP EVENT IF EXISTS `auto_reset_robot_status`;
delimiter ;;
CREATE DEFINER = `root`@`localhost` EVENT `auto_reset_robot_status`
ON SCHEDULE
EVERY '1' MINUTE STARTS '2025-03-26 19:38:32'
DO BEGIN
    UPDATE friendship 
    SET is_robot = 1 
    WHERE is_robot = 0 
    AND robot_switch_time <= NOW() - INTERVAL 60 MINUTE;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table friendships
-- ----------------------------
DROP TRIGGER IF EXISTS `update_robot_time`;
delimiter ;;
CREATE TRIGGER `update_robot_time` BEFORE UPDATE ON `friendships` FOR EACH ROW BEGIN
    -- 当 is_robot 从其他值变为 0 时更新
    IF NEW.is_robot = 0 AND OLD.is_robot != NEW.is_robot THEN
        SET NEW.robot_switch_time = NOW();
    END IF;
END
;;
delimiter ;

SET FOREIGN_KEY_CHECKS = 1;
