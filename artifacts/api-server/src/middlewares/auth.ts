import type { Request, Response, NextFunction } from "express";
import { getUserBySession, readSessionCookie } from "../lib/auth";
import type { User } from "@workspace/db";

declare module "express-serve-static-core" {
  interface Request {
    user?: User;
  }
}

export async function requireAuth(req: Request, res: Response, next: NextFunction): Promise<void> {
  const token = readSessionCookie(req);
  const user = await getUserBySession(token);
  if (!user) {
    res.status(401).json({ error: "Unauthorized" });
    return;
  }
  req.user = user;
  next();
}

export function requireRole(...roles: string[]) {
  return async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    const token = readSessionCookie(req);
    const user = await getUserBySession(token);
    if (!user) {
      res.status(401).json({ error: "Unauthorized" });
      return;
    }
    if (!roles.includes(user.role)) {
      res.status(403).json({ error: "Forbidden" });
      return;
    }
    req.user = user;
    next();
  };
}
