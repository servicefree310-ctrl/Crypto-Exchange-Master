import { Router, type IRouter } from "express";
import healthRouter from "./health";
import authRouter from "./auth";
import adminRouter from "./admin";
import publicRouter from "./public";
import publicUserRouter from "./public-user";
import otpRouter from "./otp";

const router: IRouter = Router();

router.use(healthRouter);
router.use(authRouter);
router.use(adminRouter);
router.use(publicRouter);
router.use(publicUserRouter);
router.use(otpRouter);

export default router;
